import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/theme/app_theme.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/pages/wallet_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockWalletBloc bloc;
  late MockAuthBloc authBloc;

  setUp(() {
    bloc = MockWalletBloc();
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthState(testUser),
    );
  });

  Future<void> pump(WidgetTester tester, WalletState state) {
    whenListen(bloc, const Stream<WalletState>.empty(), initialState: state);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<WalletBloc>.value(value: bloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: WalletPage(clock: () => fixedNow),
        ),
      ),
    );
  }

  testWidgets('first-load failure shows a full error with a working retry', (
    tester,
  ) async {
    await pump(
      tester,
      const WalletState(
        status: WalletStatus.failure,
        failure: NetworkFailure(),
      ),
    );

    expect(find.byKey(const Key('wallet_error')), findsOneWidget);
    expect(find.text(const NetworkFailure().message), findsOneWidget);

    await tester.tap(find.text('Try again'));
    verify(() => bloc.add(const WalletRefreshRequested())).called(1);
  });

  testWidgets('cached data with a network failure shows the offline banner', (
    tester,
  ) async {
    await pump(
      tester,
      const WalletState()
          .withSnapshot(
            snapshot(),
            isFromCache: true,
            status: WalletStatus.loading,
          )
          .copyWith(
            status: WalletStatus.failure,
            failure: const NetworkFailure(),
          ),
    );

    expect(find.byKey(const Key('wallet_offlineBanner')), findsOneWidget);
    expect(find.textContaining("You're offline"), findsOneWidget);
    expect(find.text('₦250,000.00'), findsOneWidget);
    expect(find.text('Transaction 0'), findsOneWidget);
  });

  testWidgets('an empty wallet shows the empty state', (tester) async {
    await pump(
      tester,
      const WalletState().withSnapshot(
        snapshot(transactions: const [], nextCursor: null),
        isFromCache: false,
        status: WalletStatus.ready,
      ),
    );

    expect(find.byKey(const Key('wallet_empty')), findsOneWidget);
  });

  testWidgets('header greets the signed-in user and shows their account', (
    tester,
  ) async {
    await pump(
      tester,
      const WalletState().withSnapshot(
        snapshot(),
        isFromCache: false,
        status: WalletStatus.ready,
      ),
    );

    expect(find.text('Good afternoon'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('AO'), findsOneWidget);
    expect(find.text('3012345678'), findsOneWidget);
  });

  testWidgets('transactions are grouped under day headers', (tester) async {
    await pump(
      tester,
      const WalletState().withSnapshot(
        snapshot(),
        isFromCache: false,
        status: WalletStatus.ready,
      ),
    );

    // fixedNow is 12:00, and tx(n) is n hours earlier, so the first rows are
    // today and later rows fall on yesterday.
    expect(find.text('TODAY'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('YESTERDAY'), 300);
    expect(find.text('YESTERDAY'), findsOneWidget);
  });

  testWidgets('the balance can be hidden', (tester) async {
    await pump(
      tester,
      const WalletState().withSnapshot(
        snapshot(),
        isFromCache: false,
        status: WalletStatus.ready,
      ),
    );

    await tester.tap(find.byKey(const Key('balance_toggleVisibility')));
    await tester.pumpAndSettle();

    expect(find.text('₦250,000.00'), findsNothing);
    expect(find.text('₦ • • • • • •'), findsOneWidget);
  });
}
