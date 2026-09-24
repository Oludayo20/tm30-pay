import 'package:tm30_pay/features/wallet/domain/transaction.dart';
import 'package:tm30_pay/features/wallet/domain/transaction_page.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_snapshot.dart';

final DateTime fixedNow = DateTime(2026, 9, 24, 12);

Transaction tx(int n, {TransactionStatus status = TransactionStatus.success}) =>
    Transaction(
      id: 'txn_${n.toString().padLeft(4, '0')}',
      title: 'Transaction $n',
      amount: n * 1000,
      direction: n.isEven
          ? TransactionDirection.credit
          : TransactionDirection.debit,
      status: status,
      createdAt: fixedNow.subtract(Duration(hours: n)),
    );

/// Transactions numbered [from] up to, but not including, [to].
List<Transaction> txs(int from, int to) => [
  for (var i = from; i < to; i++) tx(i),
];

WalletSnapshot snapshot({
  int balance = 25000000,
  List<Transaction>? transactions,
  String? nextCursor = 'txn_0019',
}) => WalletSnapshot(
  balance: balance,
  transactions: transactions ?? txs(0, 20),
  nextCursor: nextCursor,
  asOf: fixedNow,
);

TransactionPage page(int from, int to, {String? nextCursor}) =>
    TransactionPage(items: txs(from, to), nextCursor: nextCursor);

TransferReceipt receipt({int amount = 500000, int newBalance = 24500000}) =>
    TransferReceipt(
      transaction: Transaction(
        id: 'txn_9999',
        title: 'Transfer to Ada Obi',
        amount: amount,
        direction: TransactionDirection.debit,
        status: TransactionStatus.success,
        createdAt: fixedNow,
        counterpartyAccount: '0123456789',
      ),
      newBalance: newBalance,
    );
