# bloc/sign_in/: SignInBloc

State of the sign-in form: field values, which errors to show, and submission.

| File | What it does |
|---|---|
| `sign_in_bloc.dart` | Handles field changes, blur and submit. `SignInSubmitted` uses `droppable()` plus a status check, so a double tap, or a tap after success, cannot sign in twice. It never navigates: the router does that when `AuthBloc` changes. |
| `sign_in_event.dart` | `SignInEmailChanged`, `SignInPasswordChanged`, `SignInFieldBlurred(field)`, `SignInSubmitted`. |
| `sign_in_state.dart` | Values, `touched` fields, `submitAttempted`, status and failure. `visibleEmailError` and `visiblePasswordError` show errors only once a field has been left or the user has tried to submit. |
