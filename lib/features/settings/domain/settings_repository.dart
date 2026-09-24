import 'theme_preference.dart';

abstract interface class SettingsRepository {
  /// The saved preference, or [ThemePreference.system] if none was saved.
  Future<ThemePreference> readThemePreference();

  Future<void> saveThemePreference(ThemePreference preference);
}
