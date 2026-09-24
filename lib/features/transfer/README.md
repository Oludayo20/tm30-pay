# features/transfer/

The send-money flow: form with inline validation, then confirmation, then submitting, then success or failure. It uses `WalletRepository.sendMoney`. It never calls `WalletBloc`: the wallet updates itself from the repository's `completedTransfers` stream.

| Folder | Purpose |
|---|---|
| `domain/` | Transfer business rules (validators). |
| `presentation/` | `TransferBloc`, the send-money page, confirmation sheet and success view. |
