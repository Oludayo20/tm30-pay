# transfer/domain/

| File | What it does |
|---|---|
| `transfer_validators.dart` | Pure validators returning error enums: recipient name (letters, spaces, hyphens, apostrophes), account number (exactly 10 digits), amount (valid format, more than ₦0, at most ₦5,000,000 per transfer) and note (100 characters or fewer). There is **no balance check** here: the balance on screen may be cached, so the server decides and returns "insufficient funds". |
