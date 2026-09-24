import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/theme/app_theme.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tm30_pay/features/settings/domain/theme_preference.dart';
import 'package:tm30_pay/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:tm30_pay/features/settings/presentation/pages/settings_page.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockAuthBloc authBloc;
  late MockWalletBloc walletBloc;
  late MockThemeBloc themeBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    walletBloc = MockWalletBloc();
    themeBloc = MockThemeBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthState(testUser),
    );
    whenListen(
      themeBloc,
      const Stream<ThemeState>.empty(),
      initialState: const ThemeState(ThemePreference.system),
    );
  });

  Future<void> pump(WidgetTester tester, WalletState walletState) {
    // Tall enough to show the whole settings page without scrolling.
    tester.view
      ..physicalSize = const Size(800, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      walletBloc,
      const Stream<WalletState>.empty(),
      initialState: walletState,
    );
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<WalletBloc>.value(value: walletBloc),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const SettingsPage()),
      ),
    );
  }

  final live = const WalletState().withSnapshot(
    snapshot(),
    isFromCache: false,
    status: WalletStatus.ready,
  );

  testWidgets('shows the profile, account and current wallet data', (
    tester,
  ) async {
    await pump(tester, live);

    expect(find.byKey(const Key('settings_fullName')), findsOneWidget);
    expect(find.text('ada.obi@tm30.net'), findsOneWidget);
    expect(find.text('Member since March 2024'), findsOneWidget);
    expect(find.text('3012345678'), findsOneWidget);
    expect(find.text('₦250,000.00'), findsOneWidget);
    expect(find.text('20 so far'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('reports cached data as offline after a network failure', (
    tester,
  ) async {
    await pump(
      tester,
      live.copyWith(
        status: WalletStatus.failure,
        failure: const NetworkFailure(),
      ),
    );

    expect(find.text('Saved on device (offline)'), findsOneWidget);
  });

  testWidgets('choosing Dark sends a ThemePreferenceChanged event', (
    tester,
  ) async {
    await pump(tester, live);

    await tester.tap(find.text('Dark'));

    final event =
        verify(() => themeBloc.add(captureAny())).captured.single
            as ThemePreferenceChanged;
    expect(event.preference, ThemePreference.dark);
  });

  testWidgets('Sync now asks the wallet to refresh', (tester) async {
    await pump(tester, live);

    await tester.tap(find.byKey(const Key('settings_syncNow')));

    verify(() => walletBloc.add(const WalletRefreshRequested())).called(1);
  });
}
