part of 'wallet_bloc.dart';

sealed class WalletEvent {
  const WalletEvent();
}

/// Show the cached snapshot if there is one, then fetch fresh data.
final class WalletStarted extends WalletEvent {
  const WalletStarted();
}

/// Sent by pull-to-refresh and by the retry buttons.
final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}

/// The list has been scrolled close to the bottom.
final class WalletNextPageRequested extends WalletEvent {
  const WalletNextPageRequested();
}

/// Sent by the bloc itself when the repository reports a completed transfer.
/// It is private because the UI never sends it.
final class _WalletTransferCompleted extends WalletEvent {
  const _WalletTransferCompleted(this.receipt);
  final TransferReceipt receipt;
}
