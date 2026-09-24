import 'package:equatable/equatable.dart';

import 'transaction.dart';

class TransferRequest extends Equatable {
  const TransferRequest({
    required this.recipientName,
    required this.accountNumber,
    required this.amount,
    required this.idempotencyKey,
    this.note,
  });

  final String recipientName;
  final String accountNumber;

  /// In kobo.
  final int amount;
  final String? note;

  /// A unique key for this transfer. If the same request is sent twice, for
  /// example after a timeout, the backend recognises the key and only moves
  /// the money once. This backs up the checks in the UI.
  final String idempotencyKey;

  @override
  List<Object?> get props => [
    recipientName,
    accountNumber,
    amount,
    note,
    idempotencyKey,
  ];
}

class TransferReceipt extends Equatable {
  const TransferReceipt({required this.transaction, required this.newBalance});

  final Transaction transaction;
  final int newBalance;

  @override
  List<Object?> get props => [transaction, newBalance];
}
