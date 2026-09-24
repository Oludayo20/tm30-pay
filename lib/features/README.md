# lib/features/

One folder per product feature. Each follows the same layers:

- **`domain/`**: entities, repository interfaces and business rules. Pure Dart, with no Flutter and no storage code.
- **`data/`**: implementations of the domain interfaces: fake APIs, local storage, JSON mapping.
- **`presentation/`**: Blocs (event-driven, no Cubits), pages and widgets.

| Feature | What it covers |
|---|---|
| `auth/` | Sign in, the saved session, the signed-in user's profile, sign out. |
| `wallet/` | Balance, paginated and cached transaction list, transaction detail, home screen. |
| `transfer/` | The send-money form, confirmation, submission and result. |
| `settings/` | Settings screen and the saved theme mode. |

Features talk to each other only through domain types or repository streams, never by calling each other's blocs.
