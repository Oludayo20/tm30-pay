import '../../../core/error/result.dart';
import 'transaction.dart';
import 'transaction_page.dart';
import 'transfer.dart';
import 'wallet_snapshot.dart';

/// The only way the presentation layer reaches wallet data. The app uses a
/// fake backend today; a real API can be swapped in later without changing
/// any bloc or widget.
abstract interface class WalletRepository {
  static const int pageSize = 20;

  /// The last saved snapshot, or null if nothing has been saved. Reads from
  /// the device only and never touches the network.
  Future<WalletSnapshot?> readCachedSnapshot();

  /// Fetches the balance and the first page together. On success, the result
  /// replaces the saved snapshot.
  Future<Result<WalletSnapshot>> fetchOverview();

  /// Gets the page of transactions that comes after [cursor], newest first.
  Future<Result<TransactionPage>> getTransactions({
    required String cursor,
    int limit = pageSize,
  });

  Future<Result<Transaction>> getTransaction(String id);

  Future<Result<TransferReceipt>> sendMoney(TransferRequest request);

  /// Emits once for each successful transfer. The wallet bloc listens to this
  /// so the balance and list update without a manual refresh, and without the
  /// wallet and transfer blocs knowing about each other.
  Stream<TransferReceipt> get completedTransfers;

  Future<void> clearCache();
}
