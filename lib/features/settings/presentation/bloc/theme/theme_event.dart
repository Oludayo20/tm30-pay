part of 'theme_bloc.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

final class ThemePreferenceChanged extends ThemeEvent {
  const ThemePreferenceChanged(this.preference);
  final ThemePreference preference;
}
