import 'dart:async';
import 'dart:developer' as developer;

import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../domain/transaction.dart';
import '../domain/transaction_page.dart';
import '../domain/transfer.dart';
import '../domain/wallet_repository.dart';
import '../domain/wallet_snapshot.dart';
import 'fake_wallet_api.dart';
import 'wallet_cache.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({
    required this._api,
    required this._cache,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FakeWalletApi _api;
  final WalletCache _cache;
  final DateTime Function() _clock;
  final _transfers = StreamController<TransferReceipt>.broadcast();

  @override
  Stream<TransferReceipt> get completedTransfers => _transfers.stream;

  @override
  Future<WalletSnapshot?> readCachedSnapshot() => _cache.read();

  @override
  Future<Result<WalletSnapshot>> fetchOverview() => guard(() async {
    // Run both requests at the same time. Together they take as long as the
    // slower one, not the sum of both.
    final int balance;
    final TransactionPage page;
    try {
      (balance, page) = await (
        _api.getBalance(),
        _api.getTransactions(limit: WalletRepository.pageSize),
      ).wait;
    } on ParallelWaitError<
      (int?, TransactionPage?),
      (AsyncError?, AsyncError?)
    > catch (e) {
      // Rethrow the first error unchanged so guard() can map it.
      final error = (e.errors.$1 ?? e.errors.$2)!;
      Error.throwWithStackTrace(error.error, error.stackTrace);
    }

    final snapshot = WalletSnapshot(
      balance: balance,
      transactions: page.items,
      nextCursor: page.nextCursor,
      asOf: _clock(),
    );
    await _safeWrite(snapshot);
    return snapshot;
  });

  @override
  Future<Result<TransactionPage>> getTransactions({
    required String cursor,
    int limit = WalletRepository.pageSize,
  }) => guard(() => _api.getTransactions(cursor: cursor, limit: limit));

  @override
  Future<Result<Transaction>> getTransaction(String id) =>
      guard(() => _api.getTransaction(id));

  @override
  Future<Result<TransferReceipt>> sendMoney(TransferRequest request) async {
    final result = await guard(() => _api.transfer(request));
    if (result case Ok(value: final receipt)) {
      await _applyToCache(receipt);
      _transfers.add(receipt);
    }
    return result;
  }

  @override
  Future<void> clearCache() => _cache.clear();

  /// Adds the new transfer to the saved snapshot, so a relaunch while offline
  /// still shows it and the new balance.
  Future<void> _applyToCache(TransferReceipt receipt) async {
    final cached = await _cache.read();
    if (cached == null) return;
    var items = [receipt.transaction, ...cached.transactions];
    var nextCursor = cached.nextCursor;
    if (items.length > WalletRepository.pageSize) {
      items = items.sublist(0, WalletRepository.pageSize);
      nextCursor = items.last.id;
    }
    await _safeWrite(
      WalletSnapshot(
        balance: receipt.newBalance,
        transactions: items,
        nextCursor: nextCursor,
        asOf: _clock(),
      ),
    );
  }

  /// A failed cache write should never fail the request that fetched the
  /// data. The user still sees fresh data; it just won't be saved.
  Future<void> _safeWrite(WalletSnapshot snapshot) async {
    try {
      await _cache.write(snapshot);
    } catch (e) {
      developer.log('Cache write failed', error: e, name: 'cache');
    }
  }

  void dispose() => _transfers.close();
}
