# auth/presentation/pages/

| File | What it does |
|---|---|
| `sign_in_page.dart` | `SignInPage` provides a `SignInBloc`; `SignInView` renders the email and password fields (autofill, show/hide password), inline errors and a Sign in button with a spinner, and shows failures in a snackbar. |

(There is no sign-up page. The assessment only requires sign-in.)

## How the sign-in page gets you to the home page

**The page does not navigate.** Its only listener shows a snackbar when sign-in fails:

```dart
BlocListener<SignInBloc, SignInState>(
  listenWhen: (previous, current) =>
      current.status == SignInStatus.failure &&
      previous.status != SignInStatus.failure,
  listener: (context, state) => /* show state.failure!.message */,
)
```

There is no `context.go('/')` anywhere on this page. What happens when you tap **Sign in**:

1. `_submit()` hides the keyboard and sends `SignInSubmitted` to `SignInBloc`.
2. `SignInBloc` validates. If invalid, it shows the inline errors and stops. If valid, it emits `submitting`: the fields are disabled and the button shows a spinner. Then it calls `AuthRepository.signIn`.
3. The repository saves the session to secure storage and emits the user on its `userChanges` stream.
4. The app-wide `AuthBloc` receives that user and emits `AuthState(user)`.
5. The router is subscribed to `AuthBloc`. It re-runs its `redirect`, which returns `/` because the user is signed in and still on `/sign-in`, or the `?from=` deep-link target if there is one.
6. go_router **replaces** `/sign-in` with the home page. This page and its `SignInBloc` are disposed, and pressing back will not return here.

If sign-in fails, step 3 never emits a user, so the router never moves. `SignInBloc` emits `failure` and the listener above shows the error.

### Why the page is built this way

- It keeps the page simple: it renders `SignInState` and sends events, nothing else.
- Navigation rules live in one place (`lib/app/router.dart`), shared by sign-in, app launch, deep links and sign-out.
- The page can be tested without a router: `sign_in_page_test.dart` only checks the inline errors and that the repository was called.

See [../../README.md](../../README.md) for the full sequence diagram and the related concepts: streams, `emit.forEach`, `refreshListenable`, and redirect vs push.
