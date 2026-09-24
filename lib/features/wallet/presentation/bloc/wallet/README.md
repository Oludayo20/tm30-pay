# bloc/wallet/: WalletBloc

The most async-heavy bloc in the app. Each event type has an explicit concurrency rule.

| File | What it does |
|---|---|
| `wallet_bloc.dart` | `WalletStarted` emits the cached snapshot first, then fetches the overview. `WalletRefreshRequested` (`droppable()`) is used by pull-to-refresh and Retry. `WalletNextPageRequested` (`droppable()`) appends a page, deduplicates by id, and **throws the page away if a refresh replaced the list meanwhile**. `_WalletTransferCompleted` (from the repository stream) adds the new transaction to the top and updates the balance. |
| `wallet_event.dart` | Sealed events. `_WalletTransferCompleted` is private because only the bloc itself sends it. |
| `wallet_state.dart` | `WalletState`: status, balance, transactions, `nextCursor`, `isFromCache`, `asOf`, failure, and a separate `pageStatus` and `pageFailure` for the next page. Derived getters: `hasData`, `hasReachedEnd`, `isOffline`, `findTransaction(id)`. |
