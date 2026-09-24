# test/features/wallet/

| File | What it does |
|---|---|
| `fake_wallet_api_test.dart` | 3 × 20 pages with no duplicates, newest first, the cursor stays correct after a transfer, the network failure path, insufficient funds, idempotency. |
| `wallet_repository_impl_test.dart` | Cache written only on success, typed failures, transfer broadcast and added to the cache with trimming. |
| `wallet_bloc_test.dart` | Cache then network, offline flag, full error with no cache, pagination, dropped duplicate requests, end of list, retryable page failure, **stale page discarded after refresh**, live transfer update, refresh ignored while one is running. |
| `transaction_groups_test.dart` | Day grouping, first-row and last-row flags, day labels. |
| `wallet_page_test.dart` | Error with retry, offline banner, empty state, greeting with the user's name, day headers, hiding the balance. |
