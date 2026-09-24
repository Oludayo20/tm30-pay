import 'dart:math';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/fake_latency.dart';
import '../domain/transaction.dart';
import '../domain/transaction_page.dart';
import '../domain/transfer.dart';

/// An in-memory stand-in for the wallet backend. It behaves like a remote
/// API: every call is slow, list calls sometimes fail, and failures are
/// thrown as [DataException]s.
///
/// A real `HttpWalletApi` with the same public methods would replace it
/// later. The repository and everything above it would not change.
class FakeWalletApi {
  FakeWalletApi({
    this.latency = const FakeLatency(),
    this.listFailureRate = 0.15,
    int seedCount = 60,
    this.startingBalance = 25000000, // ₦250,000.00 in kobo
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now {
    _balance = startingBalance;
    _transactions = _seed(seedCount);
  }

  final FakeLatency latency;
  final double listFailureRate;
  final int startingBalance;
  final Random _random;
  final DateTime Function() _clock;

  late int _balance;

  /// Newest first, the same order the API returns them.
  late List<Transaction> _transactions;
  late int _nextId = _transactions.length + 1;
  final Map<String, TransferReceipt> _processedTransfers = {};

  Future<int> getBalance() async {
    await latency();
    return _balance;
  }

  Future<TransactionPage> getTransactions({
    String? cursor,
    required int limit,
  }) async {
    await latency();
    if (_random.nextDouble() < listFailureRate) {
      throw const NetworkException('Simulated connection drop');
    }

    var start = 0;
    if (cursor != null) {
      final index = _transactions.indexWhere((t) => t.id == cursor);
      if (index == -1) throw NotFoundException('Unknown cursor $cursor');
      start = index + 1;
    }
    final end = min(start + limit, _transactions.length);
    final items = List<Transaction>.unmodifiable(
      _transactions.sublist(start, end),
    );
    return TransactionPage(
      items: items,
      nextCursor: end < _transactions.length ? items.last.id : null,
    );
  }

  Future<Transaction> getTransaction(String id) async {
    await latency();
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    throw NotFoundException('No transaction $id');
  }

  Future<TransferReceipt> transfer(TransferRequest request) async {
    await latency();

    // A retry with the same key returns the original receipt, so the money
    // is never moved twice.
    final previous = _processedTransfers[request.idempotencyKey];
    if (previous != null) return previous;

    if (request.amount > _balance) {
      throw const InsufficientFundsException();
    }

    _balance -= request.amount;
    final transaction = Transaction(
      id: _formatId(_nextId++),
      title: 'Transfer to ${request.recipientName}',
      amount: request.amount,
      direction: TransactionDirection.debit,
      status: TransactionStatus.success,
      createdAt: _clock(),
      counterpartyAccount: request.accountNumber,
      note: request.note,
    );
    _transactions = [transaction, ..._transactions];

    final receipt = TransferReceipt(
      transaction: transaction,
      newBalance: _balance,
    );
    _processedTransfers[request.idempotencyKey] = receipt;
    return receipt;
  }

  static String _formatId(int n) => 'txn_${n.toString().padLeft(4, '0')}';

  List<Transaction> _seed(int count) {
    // A fixed seed gives the same list on every launch, which makes
    // screenshots and bug reports reproducible.
    final seeded = Random(30);
    const debits = [
      'Transfer to Adaeze Okafor',
      'MTN Airtime',
      'DSTV Subscription',
      'Ikeja Electric',
      'Chicken Republic',
      'Uber Trip',
      'Transfer to Tunde Bakare',
      'Jumia Order',
      'Spotify Premium',
    ];
    const credits = [
      'Salary - Tm30 Global',
      'Transfer from Chioma Eze',
      'Refund - Jumia',
      'Transfer from Musa Ibrahim',
    ];
    final now = _clock();

    return List.generate(count, (i) {
      final isCredit = seeded.nextDouble() < 0.25;
      final roll = seeded.nextDouble();
      final status = roll < 0.8
          ? TransactionStatus.success
          : roll < 0.92
          ? TransactionStatus.pending
          : TransactionStatus.failed;
      final titles = isCredit ? credits : debits;
      return Transaction(
        // Seeded ids count down, so the newest item has the highest number
        // and new transfers continue from there.
        id: _formatId(count - i),
        title: titles[seeded.nextInt(titles.length)],
        // ₦500 to ₦150,000, rounded to whole naira.
        amount: (500 + seeded.nextInt(149500)) * 100,
        direction: isCredit
            ? TransactionDirection.credit
            : TransactionDirection.debit,
        status: status,
        createdAt: now.subtract(Duration(hours: 7 * i + seeded.nextInt(6))),
        counterpartyAccount: List.generate(
          10,
          (_) => seeded.nextInt(10),
        ).join(),
      );
    });
  }
}
