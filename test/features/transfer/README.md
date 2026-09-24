# test/features/transfer/

| File | What it does |
|---|---|
| `transfer_validators_test.dart` | Account number, amount (format, zero, limit), recipient name and note rules. |
| `transfer_bloc_test.dart` | Invalid form never confirms; full flow builds the right request; **repeated confirms send exactly one request**; insufficient funds; idempotency key reused on retry and regenerated after an edit. |
| `send_money_page_test.dart` | Inline errors; confirmation, locked button, success, called once; insufficient-funds banner. |
