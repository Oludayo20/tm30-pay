# bloc/auth/: AuthBloc

Holds **who is signed in** for the whole app. The router watches it to choose between sign-in and the wallet; screens read the profile from `state.user`.

| File | What it does |
|---|---|
| `auth_bloc.dart` | Starts with the user read before the first frame. `AuthSubscriptionRequested` listens to `AuthRepository.userChanges` with `emit.forEach` (`restartable()`). `AuthSignOutRequested` (`droppable()`) calls `signOut()`. |
| `auth_event.dart` | Sealed events: `AuthSubscriptionRequested`, `AuthSignOutRequested`. |
| `auth_state.dart` | `AuthState(user)` with `isAuthenticated`. |
