# auth/domain/

Pure Dart: what authentication means to the app, with no storage or UI details.

| File | What it does |
|---|---|
| `auth_repository.dart` | The `AuthRepository` interface: `currentUser()` (read at startup), the `userChanges` stream (the user after sign-in, `null` after sign-out), `signIn` returning a `Result`, and `signOut`. |
| `auth_user.dart` | `AuthUser`: an immutable profile (email, full name, wallet account number, member since) with `firstName` and `initials` getters for the UI. |
| `auth_session.dart` | `AuthSession`: access token, refresh token, expiry and the `AuthUser`. Refresh token and expiry are stored now so token refresh can be added later without changing the storage format. |
| `credential_validators.dart` | `CredentialValidators.email` and `.password` (8+ characters). Each returns an error enum (`EmailError`, `PasswordError`), or null when valid. |
