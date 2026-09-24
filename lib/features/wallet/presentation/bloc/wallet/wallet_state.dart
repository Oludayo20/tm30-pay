part of 'wallet_bloc.dart';

/// Status of the overview fetch (balance plus first page).
enum WalletStatus { initial, loading, ready, failure }

/// Status of loading the next page, tracked separately so a failed next page
/// doesn't hide the list.
enum PageStatus { idle, loading, failure }

final class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance,
    this.transactions = const [],
    this.nextCursor,
    this.isFromCache = false,
    this.asOf,
    this.failure,
    this.pageStatus = PageStatus.idle,
    this.pageFailure,
  });

  final WalletStatus status;

  /// In kobo. Null until something has loaded, from the cache or the network.
  final int? balance;
  final List<Transaction> transactions;
  final String? nextCursor;

  /// True while the data on screen comes from the device and has not yet
  /// been confirmed by the server.
  final bool isFromCache;
  final DateTime? asOf;
  final Failure? failure;
  final PageStatus pageStatus;
  final Failure? pageFailure;

  bool get hasData => balance != null;
  bool get hasReachedEnd => nextCursor == null;

  /// True if the latest fetch failed for network reasons while older data is
  /// on screen. The UI shows the offline banner.
  bool get isOffline =>
      hasData && status == WalletStatus.failure && failure is NetworkFailure;

  /// Checks the loaded items so the detail screen can open instantly when
  /// the user taps a row.
  Transaction? findTransaction(String id) {
    for (final t in transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  WalletState withSnapshot(
    WalletSnapshot snapshot, {
    required bool isFromCache,
    required WalletStatus status,
  }) {
    return WalletState(
      status: status,
      balance: snapshot.balance,
      transactions: snapshot.transactions,
      nextCursor: snapshot.nextCursor,
      isFromCache: isFromCache,
      asOf: snapshot.asOf,
    );
  }

  WalletState copyWith({
    WalletStatus? status,
    int? balance,
    List<Transaction>? transactions,
    String? nextCursor,
    bool clearNextCursor = false,
    Failure? failure,
    PageStatus? pageStatus,
    Failure? pageFailure,
  }) {
    final nextStatus = status ?? this.status;
    final nextPageStatus = pageStatus ?? this.pageStatus;
    return WalletState(
      status: nextStatus,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isFromCache: isFromCache,
      asOf: asOf,
      // Each failure only makes sense while its status is "failure". Clear
      // it whenever the status changes to anything else.
      failure: nextStatus == WalletStatus.failure
          ? (failure ?? this.failure)
          : null,
      pageStatus: nextPageStatus,
      pageFailure: nextPageStatus == PageStatus.failure
          ? (pageFailure ?? this.pageFailure)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    balance,
    transactions,
    nextCursor,
    isFromCache,
    asOf,
    failure,
    pageStatus,
    pageFailure,
  ];
}
