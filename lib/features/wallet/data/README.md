# wallet/data/

| File | What it does |
|---|---|
| `fake_wallet_api.dart` | In-memory backend: 60 seeded transactions (same list every launch), starting balance ₦250,000, 600–1200 ms latency, 15% of list calls fail with `NetworkException`, cursor pagination, and transfers that reject amounts above the balance (`InsufficientFundsException`). It also honours idempotency keys. |
| `wallet_cache.dart` | `WalletCache`: saves and reads one `WalletSnapshot` as JSON in `shared_preferences`. A corrupt cache is treated as empty. |
| `wallet_json.dart` | JSON mapping for `Transaction` and `WalletSnapshot`. It lives in the data layer so the domain entities have no serialisation code. |
| `wallet_repository_impl.dart` | `WalletRepositoryImpl`: fetches balance and first page in parallel and writes them to the cache. It maps errors with `guard()`, adds each completed transfer to the cache (trimmed to one page), and broadcasts receipts on `completedTransfers`. |
