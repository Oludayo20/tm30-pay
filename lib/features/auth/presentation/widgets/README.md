# auth/presentation/widgets/

Auth UI that other features reuse (home header, settings).

| File | What it does |
|---|---|
| `user_avatar.dart` | `UserAvatar`: a round avatar with the user's initials on a brand-tinted background. |
| `sign_out_dialog.dart` | `confirmSignOut(context)`: shows a confirmation dialog and, if confirmed, sends `AuthSignOutRequested` to `AuthBloc`. |
