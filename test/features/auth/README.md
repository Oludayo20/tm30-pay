# test/features/auth/

| File | What it does |
|---|---|
| `credential_validators_test.dart` | Email and password (8+ characters) rules. |
| `auth_user_test.dart` | Initials and first name; the fake API's name-from-email and stable account number. |
| `sign_in_bloc_test.dart` | Errors hidden until a field is blurred; invalid input never calls the repository; **one sign-in despite double taps and taps after success**. |
| `sign_in_page_test.dart` | Inline errors on empty submit; valid input calls the repository. |
