# settings/domain/

| File | What it does |
|---|---|
| `theme_preference.dart` | `ThemePreference { system, light, dark }`: a plain enum, so the domain does not depend on Flutter's `ThemeMode`. |
| `settings_repository.dart` | The `SettingsRepository` interface: `readThemePreference()` and `saveThemePreference()`. |
