# transfer/presentation/bloc/: TransferBloc

Status flow: `editing → confirming → submitting → success | failure`.

| File | What it does |
|---|---|
| `transfer_bloc.dart` | Handles field changes and blur, review (validates, then moves to `confirming` with an idempotency key), cancel, and confirm. Double submission is prevented by `droppable()` on confirm, an "only from confirming" check, a disabled button, and the idempotency key. |
| `transfer_event.dart` | `TransferFieldChanged(field, value)`, `TransferFieldBlurred`, `TransferReviewRequested`, `TransferReviewCancelled`, `TransferConfirmed`. |
| `transfer_state.dart` | Raw field text, errors per field, `touched` and `submitAttempted`, status, idempotency key, failure and receipt. `withField()` drops the key when anything is edited, so an edited form counts as a new transfer. `toRequest()` builds the `TransferRequest`. |
