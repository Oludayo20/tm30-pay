# lib/app/

App-level wiring that belongs to no single feature.

| File | What it does |
|---|---|
| `app.dart` | `Tm30PayApp`. Creates `AuthBloc`, `ThemeBloc` and the router once, provides the repositories and blocs to the widget tree, and builds `MaterialApp.router` with the light and dark themes. The theme mode comes from `ThemeBloc`. |
| `router.dart` | go_router setup. The `redirect` is the single auth gate: signed-out users go to `/sign-in?from=…`, and after sign-in they return to where they were going. Signed-in routes sit inside a `ShellRoute` that provides the `WalletBloc`, so it is closed on sign-out. It also contains the small `Listenable` that re-runs the redirect whenever the auth state changes. |
| `routes.dart` | `AppRoutes`: every route path in one place (`/`, `/sign-in`, `/send`, `/settings`, `/transactions/:id`). Widgets never hard-code path strings. |
