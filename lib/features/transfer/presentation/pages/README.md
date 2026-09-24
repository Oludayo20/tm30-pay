# transfer/presentation/pages/

| File | What it does |
|---|---|
| `send_money_page.dart` | Provides a `TransferBloc` and renders the form: recipient, account number (digits only, max 10), amount (₦ prefix, available balance hint), optional note, failure banner, and Continue / Try again. It opens the confirmation sheet when the status becomes `confirming`, shows the success view on success, and blocks the back gesture while submitting. |

---

## How a transfer updates the rest of the app live

This page starts the live update, but **it never touches the wallet itself**. It has no reference to `WalletBloc`'s events, doesn't pop with a result, and doesn't ask the home screen to refresh. It only talks to its own `TransferBloc`.

### What this page does

1. **Form → review.** Each keystroke sends `TransferFieldChanged`, and each field that loses focus sends `TransferFieldBlurred`. **Continue** sends `TransferReviewRequested`. If the form is valid, `TransferBloc` emits `confirming`, and this page's `BlocConsumer` listener opens the confirmation sheet.
2. **Confirm → submit.** **Confirm and send** sends `TransferConfirmed`. The bloc emits `submitting`: the fields lock, the button shows a spinner, and `PopScope` blocks the back gesture. Then it calls `WalletRepository.sendMoney(request)`.
3. **Result.** `Ok(receipt)` becomes `success`, and the page swaps the form for `TransferSuccessView` (amount, recipient, new balance). `Err(failure)` becomes `failure`, and the page shows the error banner and "Try again", keeping the same idempotency key.

### What happens everywhere else at the same moment

Inside `sendMoney`, before returning the result to this page, the repository:

1. updates the **device cache**, so an offline relaunch shows the transfer and the new balance, and
2. emits the receipt on its **`completedTransfers` broadcast stream**.

`WalletBloc` (shared by every signed-in screen through the `ShellRoute`) is subscribed to that stream. It updates the balance and adds the transaction to the top of its list. As a result:

- **On this page:** the "Available: ₦…" hint under the amount field reads `context.select((WalletBloc b) => b.state.balance)`, so it shows the new balance straight away.
- **Behind this page:** the home screen is still in the navigation stack. Its `BlocBuilder` has already rebuilt, so when you tap **Done**, `context.pop()` reveals a home screen that already shows the new balance and the new transaction at the top of the list. There's no refresh and no spinner.
- **Settings:** the "Wallet data" section updates too, if it's open.

```
SendMoneyPage ──TransferConfirmed──▶ TransferBloc ──sendMoney()──▶ WalletRepository
                                          ▲                          │  │
                          Ok(receipt) ────┘                          │  └─ completedTransfers.add(receipt)
                                                                     │                    │
                                                          cache updated                   ▼
                                                                                    WalletBloc
                                                                   (balance + new row, emits new state)
                                                                                          │
                                                        Home / Send hint / Settings rebuild ◀┘
```

### Why the page doesn't update the wallet directly

The obvious alternatives are worse:

- **`context.pop(receipt)` and let home refresh.** This only works for the screen directly underneath. Settings and the send-form hint would stay stale, and a deep-linked flow might have no home screen underneath at all.
- **Calling `context.read<WalletBloc>().add(...)` from this page.** This couples the transfer feature to the wallet feature's internals. Every future screen that moves money would have to remember to do it.
- **Refetching after success.** This costs an extra network call and a loading flash, and it could hit the 15% simulated failure right after a successful transfer.

With the repository stream, any code path that successfully moves money updates every screen. That includes a future "pay a bill" screen: it gets live updates for free.

### Double-submission safety

Live updates must never count one transfer twice:

- **In the UI and bloc:** `droppable()` on `TransferConfirmed`, a status check that only submits from `confirming`, a disabled button, and `PopScope`.
- **Server-side:** every `TransferRequest` carries an idempotency key. A retry with the same key returns the original receipt without moving money again.
- **In `WalletBloc`:** the handler skips a transaction whose id is already in the list, so a replayed receipt cannot add a duplicate row.

See [../../../wallet/presentation/pages/README.md](../../../wallet/presentation/pages/README.md) for the wallet side in detail (immutable state, `Equatable`, keys, `select` vs `watch`, and how server push would fit into the same pattern).
