# lib/core/theme/

| File | What it does |
|---|---|
| `app_theme.dart` | `AppTheme.light()` and `AppTheme.dark()`: Material 3 `ColorScheme.fromSeed` with Tm30 blue `#0B5FFF` (used exactly as the primary colour in light mode), plus shared input, button and snackbar styles. Also defines `StatusColors`, a `ThemeExtension` with success, pending and failed colours for each theme, read with `context.statusColors`. |
