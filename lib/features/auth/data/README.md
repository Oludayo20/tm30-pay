# auth/data/

| File | What it does |
|---|---|
| `fake_auth_api.dart` | Stands in for the auth backend. After the simulated delay it accepts any validated credentials and returns fake tokens and a profile. The name comes from the email (`ada.obi@…` becomes "Ada Obi"), and each email always gets the same account number. |
| `session_storage.dart` | Reads, writes and deletes the `AuthSession` as JSON in `flutter_secure_storage` (iOS Keychain or Android Keystore). If the stored session can't be read, it is cleared and the user is treated as signed out. |
| `auth_repository_impl.dart` | `AuthRepositoryImpl`: calls the API through `guard()`, saves the session, and emits on the `userChanges` broadcast stream after sign-in and sign-out. |
