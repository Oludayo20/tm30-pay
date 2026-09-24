import 'package:flutter/material.dart';

import '../domain/theme_preference.dart';

/// Maps the domain preference to Flutter's ThemeMode, plus the label and
/// icon used in the settings screen.
extension ThemePreferenceUi on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  String get label => switch (this) {
    ThemePreference.system => 'System',
    ThemePreference.light => 'Light',
    ThemePreference.dark => 'Dark',
  };

  IconData get icon => switch (this) {
    ThemePreference.system => Icons.brightness_auto_rounded,
    ThemePreference.light => Icons.light_mode_rounded,
    ThemePreference.dark => Icons.dark_mode_rounded,
  };
}
