# Tm30 Pay

A first vertical slice of the Tm30 Pay wallet: sign in, view transactions, and send money. It runs against an in-memory fake backend that behaves like a real one: every call takes 600–1200 ms, 15% of list requests fail, and it rejects transfers larger than the balance.

- Flutter stable 3.47 / Dart 3.13, Material 3, Tm30 blue (`#0B5FFF`), light and dark themes that follow the system
- State management: **Bloc** (event-driven `Bloc` classes throughout, no Cubits)
- Stretch goal: **go_router with a deep link to transaction detail**
- Extras: a profile header and settings screen (account details, what wallet data is on the device, sync) and a **System/Light/Dark theme switcher** that is saved between launches

How the dummy data is generated and what is stored on the device (with a script to regenerate and inspect it): see [tool/README.md](tool/README.md).

Every folder under `lib/` and `test/` has its own `README.md` listing each file and what it does. Start with [lib/README.md](lib/README.md).

## Setup

```bash
flutter pub get
flutter run            # iOS simulator or Android emulator
flutter test           # 65 tests: unit, bloc and widget
flutter analyze        # no issues
```

Sign in with any valid email and a password of 8 or more characters.

Deep link to a transaction (the app must be installed; if signed out, you go to that transaction after signing in):

```bash
xcrun simctl openurl booted "tm30pay://tm30pay.app/transactions/txn_0042"
adb shell am start -a android.intent.action.VIEW -d "tm30pay://tm30pay.app/transactions/txn_0042"
```

## Architecture

Code is grouped by feature first. Each feature is then split into layers, and dependencies only point inwards: `presentation → domain ← data`.

```
lib/
  main.dart                 composition root: all concrete classes are created here
  app/                      MaterialApp, router (auth redirect), route paths
  core/
    error/                  sealed Failure, Result<T>, DataException, guard()
    theme/                  AppTheme + StatusColors ThemeExtension
    utils/                  Money (integer kobo), FakeLatency, id generator
    widgets/                AppTextField, MessageView, ResponsiveCenter
  features/
    auth/
      domain/               AuthRepository interface, AuthUser, AuthSession, credential validators
      data/                 AuthRepositoryImpl, SessionStorage (secure storage), FakeAuthApi
      presentation/         AuthBloc (signed-in user), SignInBloc (form), SignInPage, UserAvatar
    wallet/
      domain/               Transaction, TransactionPage, WalletSnapshot, Transfer*, WalletRepository
      data/                 WalletRepositoryImpl, FakeWalletApi, WalletCache, JSON mapping
      presentation/         WalletBloc, TransactionDetailBloc, pages, widgets
    transfer/
      domain/               transfer validators (business rules)
      presentation/         TransferBloc, SendMoneyPage, confirmation sheet, success view
    settings/
      domain/               ThemePreference, SettingsRepository interface
      data/                 SettingsRepositoryImpl (shared_preferences)
      presentation/         ThemeBloc, SettingsPage (profile, account, wallet data, appearance)
```

**How the data layer works.**

- The domain defines `WalletRepository` as an interface. `WalletRepositoryImpl` implements it with two parts: a data source (`FakeWalletApi`, standing in for an HTTP client) and a cache (`WalletCache`).
- The fake throws transport-style exceptions such as `NetworkException`. `guard()` is the only place those become typed `Failure`s.
- Every repository method returns a `Result<T>`, so the UI never sees an exception.
- Moving to a real API means writing `HttpWalletApi` with the same methods and changing one line in `main.dart`.

The spec asks for "a repository interface with an in-memory fake". I put the fake one level lower, as a data source, so the caching and error mapping in the repository are real code that would ship unchanged.

**Other decisions.**

- **Business rules live in the domain as pure functions.** Validators return error enums. The presentation layer turns them into strings, which is also where localisation would plug in. Widgets only render state and send events.
- **Immutable models.** Every entity and state is an `Equatable` with `final` fields and a hand-written `copyWith`. I chose this over `freezed` to avoid build_runner for a project this size.
- **Money is an `int` in kobo.** Using `double` would introduce rounding errors, which is not acceptable in a wallet.
- **Cursor pagination, not page numbers.** A transfer inserts a row at the top of the list. With offset pagination, every later page would shift by one and repeat an item. The cursor is the id of the last loaded item, so pages stay correct. A test covers this.

### Navigation and session

- `AuthBloc` is created once at the app root. The session (tokens and profile) and the theme preference are read **before** `runApp`, in parallel, so a signed-in user never sees the sign-in screen or the wrong theme flash on relaunch.
- The go_router `redirect` is the single place that decides who may see which route. It re-runs whenever `AuthBloc` emits. If a signed-out user opens a deep link, the redirect remembers it as `?from=` and continues there after sign-in. It only follows internal paths starting with `/`.
- Signed-in routes sit under a `ShellRoute` that provides the `WalletBloc`. On sign-out, the shell is removed and the bloc is closed. `main.dart` also clears the wallet cache on sign-out, so the next user on the device starts fresh.

## State management: Bloc (and why not Cubit)

I used `flutter_bloc` with event classes everywhere. In this app the hard part is **concurrency**: pull-to-refresh racing infinite scroll, double taps on "Send", and transfers arriving while a page is loading. With Bloc, each event type gets an explicit **event transformer** that states its concurrency rule and can be tested. Cubit methods would need hand-written flags and locks for the same guarantees.

| Event | Transformer | Why |
|---|---|---|
| `WalletRefreshRequested` | `droppable()` | A second pull while a refresh is running is ignored, not queued |
| `WalletNextPageRequested` | `droppable()` | The scroll listener fires on every frame, but only one page loads at a time |
| `TransferConfirmed` | `droppable()` | First of four guards against double submission |
| `SignInSubmitted` | `droppable()` | Double tap on sign in |
| `AuthSubscriptionRequested` | `restartable()` | One live subscription to the signed-in user |
| `ThemePreferenceChanged` | `sequential()` | Saves choices in order, so the last tap is the one stored |

Other benefits: every state change has a named cause (`WalletNextPageRequested`), which reads well in logs and in `bloc_test` expectations. Blocs never call each other. `WalletBloc` learns about completed transfers from the repository's `completedTransfers` stream, so the transfer feature and the wallet feature don't depend on each other.

## Behaviour of the main requirements

**Cache and offline.**

- `WalletStarted` first emits the saved snapshot (balance plus first 20 items from `shared_preferences`), so the list appears instantly. It then fetches fresh data.
- If the fetch fails with a `NetworkFailure` while data is on screen, `state.isOffline` is true. The page shows an "You're offline · Last updated …" banner with a Retry button and keeps the data.
- With no cache, the page shows a full error view with retry.

**Pagination edge cases.**

- A next page that resolves *after* a refresh replaced the list is discarded. The bloc compares the cursor it requested with the current one.
- Duplicate ids are filtered out.
- The footer shows a spinner while loading, "Tap to retry" on failure, and "You're all caught up" at the end.

**Send money.**

- Inline validation: errors appear once you leave a field, or for every field after you tap Continue.
- Then a confirmation sheet, then submitting, then a success screen or an error banner with "Try again".
- On success the repository broadcasts the receipt, and `WalletBloc` updates the balance and adds the transaction to the top of the list without a refresh. The cached snapshot is updated too, so an offline relaunch shows the transfer.

**Double submission** is prevented at four levels:

1. `droppable()` on `TransferConfirmed`.
2. The bloc only submits from the `confirming` status, so late taps are ignored.
3. The button is disabled and `PopScope` blocks leaving the screen while submitting.
4. Each transfer carries an **idempotency key**, which the fake backend honours. The key is kept when you retry the same transfer after a failure, and replaced as soon as you edit a field. A timeout followed by a retry therefore cannot debit twice.

**Insufficient funds** is decided by the server, not in the form. The balance on screen may be cached and out of date, so the form only shows it as a hint ("Available: ₦…"). The fake backend returns a typed `InsufficientFundsFailure`.

## Tests (65)

| Kind | File | What it protects |
|---|---|---|
| Unit | `money_test`, `*_validators_test` | Money parsing (kobo, 2 decimal places), email, password, account number and amount rules |
| Unit | `fake_wallet_api_test` | 3 × 20 pages with no duplicates, cursor stays correct after a transfer, 15% failure path, insufficient funds, idempotency |
| Unit | `wallet_repository_impl_test` | Exceptions mapped to typed failures, cache written only on success, transfer added to the cache and trimmed |
| Bloc | `wallet_bloc_test` | Cache then network, offline flag, full error with no cache, append and dedupe, dropped duplicates, stale page discarded after refresh, live transfer update |
| Bloc | `transfer_bloc_test`, `sign_in_bloc_test` | Full status flow, **exactly one request under repeated confirms**, idempotency key reused or regenerated, errors hidden until a field is blurred |
| Widget | `wallet_page_test` | Error with working retry, offline banner with cached data, empty state |
| Widget | `send_money_page_test`, `sign_in_page_test` | Inline errors, confirmation, button locked while submitting, success view, insufficient-funds banner |
| Unit / Bloc | `transaction_groups_test`, `auth_user_test`, `theme_bloc_test` | Day grouping and labels, initials and profile derivation, theme saved and applied |
| Widget | `settings_page_test`, `wallet_page_test` (home) | Profile and wallet data rows, offline source, theme switch, Sync now, greeting, day headers, hiding the balance |

Writing the tests caught one real bug: `SignInBloc` could sign in again if the button was tapped *after* a successful sign-in, because `droppable()` only covers the time while the handler is running. It now also checks the status.

## Trade-offs and honest limitations

- **"Offline" means "the last request failed with a network error".** There is no `connectivity_plus`. That package reports whether a network interface exists, not whether the server can be reached. A reachability signal would be a good addition, but it would supplement the failure-based check, not replace it.
- **The fake backend resets on cold start.** It lives in memory, so transfers made in one session are gone from the "server" after a relaunch. The cached first page still shows them until the first successful fetch replaces it.
- **The cache is one JSON value in `shared_preferences`.** That is fine for 20 rows. It is the wrong tool for large histories (see below).
- **Tokens are never refreshed.** `AuthSession` already stores an access token, a refresh token and `expiresAt`, so the storage format won't need to change.
- **The profile comes from the fake API.** The name is derived from the email, and each email gets the same account number every time. A real API would return the registered profile.
- **No localisation**, though every user-facing string comes from one mapping layer. **No golden tests.** The stretch goal I picked was go_router with deep links.
- **Balance and first page are fetched in parallel, and both must succeed.** A real API would probably return them from one "wallet home" endpoint.

## With another day

1. Replace the fake with a `dio` HTTP client that has an auth interceptor (see token refresh below). Generate typed DTOs from an OpenAPI spec.
2. Move the cache to **drift** (SQLite) with a real `transactions` table (see scaling below).
3. Add an integration test (`integration_test`) for sign in → send → balance updated, run in CI on both platforms. Add golden tests for the transaction tile in light and dark mode.
4. Accessibility pass: semantics labels on amounts ("debit of five thousand naira"), large text sizes, contrast checks for the status colours.
5. Error reporting (Sentry or Crashlytics) connected to `guard()`, and a `BlocObserver` for breadcrumbs.
6. Biometric unlock on relaunch, and a check against a saved-beneficiaries list before sending.

## Discussion notes

### Token refresh

- Put a `dio` `QueuedInterceptor` (or `fresh_dio`) in the data layer.
- On a 401, **one** refresh runs while every other request that got a 401 waits for it. When it finishes, they retry with the new token. Only one refresh can run at a time, because refresh tokens usually rotate: two parallel refreshes would invalidate each other.
- If the refresh itself fails, clear `SessionStorage` and emit `AuthStatus.unauthenticated` on the existing `statusChanges` stream. The router redirect then signs the user out. No widget or bloc needs to change.
- Optionally refresh early when `expiresAt` is within about 60 seconds, to save a round trip.
- **Transfers are safe to retry after a refresh because of the idempotency key.**

### Scaling the list to 100,000 transactions

- **Server:** the cursor pagination stays as it is. A keyset query (`WHERE (created_at, id) < (?, ?) ORDER BY created_at DESC, id DESC LIMIT 20`) takes the same time on any page, unlike `OFFSET`. Filters and search run on the server.
- **Client memory:** `WalletBloc` currently keeps every loaded item in a `List`. 100k small objects fit in memory, but copying the list on every append doesn't scale.
  - Move storage to drift or SQLite. The repository writes each page to the database.
  - The UI watches a paged query stream (`LIMIT/OFFSET` on the local table, or a sliding window), and the bloc holds only a window of items plus cursors.
  - This also makes the whole history available offline and searchable, instead of just the first page.
- **Rendering:** `SliverList` already builds only visible rows. Adding `itemExtent` or `prototypeItem` would let Flutter skip layout for off-screen rows. Grouping by month with sticky headers helps people find their way through a long list.
- **Sync:** once there is a local database, fetch new items with an "updated since" cursor instead of re-fetching page 1. Server push (FCM or WebSocket) can tell the app when new transactions arrive.
