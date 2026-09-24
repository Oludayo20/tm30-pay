import 'package:equatable/equatable.dart';

enum TransactionStatus { success, pending, failed }

enum TransactionDirection { credit, debit }

/// An immutable ledger entry. [amount] is always positive and in kobo;
/// [direction] says which way the money moved.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.direction,
    required this.status,
    required this.createdAt,
    this.counterpartyAccount,
    this.note,
  });

  final String id;
  final String title;
  final int amount;
  final TransactionDirection direction;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? counterpartyAccount;
  final String? note;

  bool get isCredit => direction == TransactionDirection.credit;

  /// Positive for credits and negative for debits.
  int get signedAmount => isCredit ? amount : -amount;

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    direction,
    status,
    createdAt,
    counterpartyAccount,
    note,
  ];
}
