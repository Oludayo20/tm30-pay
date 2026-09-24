# lib/

All of the app's Dart code. The code is grouped **by feature first**, and each feature is then split into `data`, `domain` and `presentation` layers. Dependencies only point inwards: `presentation → domain ← data`.

| Item | Purpose |
|---|---|
| `main.dart` | Composition root. Creates every concrete class (fake APIs, storage, repositories), reads the saved session and theme before the first frame, clears the wallet cache on sign-out, then runs the app. |
| `app/` | App-level wiring: `MaterialApp`, the router and route paths. |
| `core/` | Shared building blocks used by every feature: errors, theme, utilities and common widgets. |
| `features/` | One folder per product feature: `auth`, `wallet`, `transfer`, `settings`. |

To move to a real backend, change the concrete classes created in `main.dart`. Nothing in the presentation layer changes.
