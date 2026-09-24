# bloc/theme/: ThemeBloc

| File | What it does |
|---|---|
| `theme_bloc.dart` | Starts with the preference read before the first frame. `ThemePreferenceChanged` (`sequential()`) emits the new mode immediately, then saves it. A failed save keeps the mode for the current session. |
| `theme_event.dart` | `ThemePreferenceChanged(preference)`. |
| `theme_state.dart` | `ThemeState(preference)`. `MaterialApp` rebuilds its `themeMode` from this. |
