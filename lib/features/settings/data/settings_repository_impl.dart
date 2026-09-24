import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_repository.dart';
import '../domain/theme_preference.dart';

/// Keeps device-level preferences in shared preferences. They are not
/// secret, and they deliberately survive sign-out, because the theme belongs
/// to the device, not to the account.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  static const _themeKey = 'theme_preference';

  final SharedPreferencesAsync _prefs;

  @override
  Future<ThemePreference> readThemePreference() async {
    try {
      final name = await _prefs.getString(_themeKey);
      return ThemePreference.values.asNameMap()[name] ?? ThemePreference.system;
    } catch (_) {
      return ThemePreference.system;
    }
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _prefs.setString(_themeKey, preference.name);
}
