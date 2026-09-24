import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:tm30_pay/features/settings/domain/settings_repository.dart';
import 'package:tm30_pay/features/settings/domain/theme_preference.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Holds the appearance setting for the whole app. MaterialApp reads it to
/// pick light, dark or system theme.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required this._repository,
    required ThemePreference initialPreference,
  }) : super(ThemeState(initialPreference)) {
    // sequential() saves the choices in the order they were made, so the
    // last tap is always the one that is stored.
    on<ThemePreferenceChanged>(_onChanged, transformer: sequential());
  }

  final SettingsRepository _repository;

  Future<void> _onChanged(
    ThemePreferenceChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.preference == state.preference) return;
    // Update the screen first, then save. The theme changes instantly even
    // if the disk write is slow.
    emit(ThemeState(event.preference));
    try {
      await _repository.saveThemePreference(event.preference);
    } catch (e) {
      // The choice still applies for this session; it just won't survive a
      // restart.
      developer.log('Could not save theme', error: e, name: 'settings');
    }
  }
}
