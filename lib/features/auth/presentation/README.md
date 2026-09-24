# auth/presentation/

| Item | Purpose |
|---|---|
| `bloc/` | `AuthBloc` (who is signed in, app-wide) and `SignInBloc` (the sign-in form). |
| `pages/` | `SignInPage`. |
| `widgets/` | Auth UI reused by other features: `UserAvatar` and the sign-out confirmation. |
| `validation_messages.dart` | Turns the domain's `EmailError` and `PasswordError` enums into the text shown under the fields. Localisation would replace the strings here. |
