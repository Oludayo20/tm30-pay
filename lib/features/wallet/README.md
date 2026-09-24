# features/wallet/

The balance, the paginated and cached transaction list, transaction detail, and the home screen.

| Folder | Purpose |
|---|---|
| `domain/` | Entities (`Transaction`, `TransactionPage`, `WalletSnapshot`, transfer types) and the `WalletRepository` interface. |
| `data/` | Fake wallet backend, the on-device cache, JSON mapping and the repository implementation. |
| `presentation/` | `WalletBloc`, `TransactionDetailBloc`, the home and detail pages, and their widgets. |

**Key behaviours:** the cached snapshot shows instantly on launch, and fresh data follows. Pages use a cursor, not an offset. The offline banner appears when a refresh fails with cached data on screen. Completed transfers reach the list through `WalletRepository.completedTransfers`.
