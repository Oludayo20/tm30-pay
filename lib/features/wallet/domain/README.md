# wallet/domain/

Immutable entities and the repository contract. Pure Dart.

| File | What it does |
|---|---|
| `transaction.dart` | `Transaction`: id, title, amount (positive `int` kobo), direction (credit or debit), status (success, pending or failed), date, and optional account and note. |
| `transaction_page.dart` | `TransactionPage`: one page of items plus `nextCursor` (null on the last page). The comments explain why a cursor is used instead of an offset. |
| `wallet_snapshot.dart` | `WalletSnapshot`: the balance and first page at a point in time (`asOf`). It is returned by an overview fetch and saved as the offline cache. |
| `transfer.dart` | `TransferRequest` (recipient, 10-digit account, amount, note, **idempotency key**) and `TransferReceipt` (the new transaction and new balance). |
| `wallet_repository.dart` | The `WalletRepository` interface: `readCachedSnapshot`, `fetchOverview`, `getTransactions(cursor)`, `getTransaction(id)`, `sendMoney`, the `completedTransfers` stream and `clearCache`. It also defines `pageSize = 20`. |
