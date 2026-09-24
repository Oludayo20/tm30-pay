import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/features/settings/domain/theme_preference.dart';
import 'package:tm30_pay/features/settings/presentation/bloc/theme/theme_bloc.dart';

import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockSettingsRepository repository;

  setUp(() {
    repository = MockSettingsRepository();
    when(() => repository.saveThemePreference(any())).thenAnswer((_) async {});
  });

  ThemeBloc build() => ThemeBloc(
    repository: repository,
    initialPreference: ThemePreference.system,
  );

  blocTest<ThemeBloc, ThemeState>(
    'applies the new mode immediately and saves it',
    build: build,
    act: (bloc) => bloc.add(const ThemePreferenceChanged(ThemePreference.dark)),
    expect: () => [const ThemeState(ThemePreference.dark)],
    verify: (_) =>
        verify(() => repository.saveThemePreference(ThemePreference.dark))
            .called(1),
  );

  blocTest<ThemeBloc, ThemeState>(
    'choosing the current mode does nothing',
    build: build,
    act: (bloc) =>
        bloc.add(const ThemePreferenceChanged(ThemePreference.system)),
    expect: () => <ThemeState>[],
    verify: (_) => verifyNever(() => repository.saveThemePreference(any())),
  );

  blocTest<ThemeBloc, ThemeState>(
    'a failed save keeps the chosen mode for this session',
    setUp: () =>
        when(() => repository.saveThemePreference(any()))
            .thenThrow(Exception('disk full')),
    build: build,
    act: (bloc) =>
        bloc.add(const ThemePreferenceChanged(ThemePreference.light)),
    expect: () => [const ThemeState(ThemePreference.light)],
  );
}
