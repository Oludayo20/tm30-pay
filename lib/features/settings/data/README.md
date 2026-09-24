# settings/data/

| File | What it does |
|---|---|
| `settings_repository_impl.dart` | Saves the theme preference by name in `shared_preferences`. It falls back to `system` if the value is missing or unreadable. The preference survives sign-out, because it belongs to the device, not the account. |
