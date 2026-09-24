import '../domain/transaction.dart';
import '../domain/wallet_snapshot.dart';

// JSON mapping lives in the data layer so the domain entities have no
// persistence code. The same mapping would be used for API responses.

extension TransactionJson on Transaction {
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'direction': direction.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'counterpartyAccount': counterpartyAccount,
    'note': note,
  };
}

Transaction transactionFromJson(Map<String, Object?> json) => Transaction(
  id: json['id']! as String,
  title: json['title']! as String,
  amount: json['amount']! as int,
  direction: TransactionDirection.values.byName(json['direction']! as String),
  status: TransactionStatus.values.byName(json['status']! as String),
  createdAt: DateTime.parse(json['createdAt']! as String),
  counterpartyAccount: json['counterpartyAccount'] as String?,
  note: json['note'] as String?,
);

extension WalletSnapshotJson on WalletSnapshot {
  Map<String, Object?> toJson() => {
    'balance': balance,
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'nextCursor': nextCursor,
    'asOf': asOf.toIso8601String(),
  };
}

WalletSnapshot walletSnapshotFromJson(Map<String, Object?> json) =>
    WalletSnapshot(
      balance: json['balance']! as int,
      transactions: (json['transactions']! as List)
          .cast<Map<String, Object?>>()
          .map(transactionFromJson)
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
      asOf: DateTime.parse(json['asOf']! as String),
    );
