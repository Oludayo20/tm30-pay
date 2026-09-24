import 'package:equatable/equatable.dart';

import 'transaction.dart';

/// The balance plus the first page of transactions at the time [asOf].
///
/// The repository returns one after every successful first-page fetch and
/// saves it to the device. On launch, or while offline, the saved copy is
/// shown instead.
class WalletSnapshot extends Equatable {
  const WalletSnapshot({
    required this.balance,
    required this.transactions,
    required this.nextCursor,
    required this.asOf,
  });

  final int balance;
  final List<Transaction> transactions;
  final String? nextCursor;
  final DateTime asOf;

  @override
  List<Object?> get props => [balance, transactions, nextCursor, asOf];
}
