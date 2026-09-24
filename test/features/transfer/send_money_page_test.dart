import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/core/theme/app_theme.dart';
import 'package:tm30_pay/features/transfer/presentation/pages/send_money_page.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_repository.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockWalletRepository repository;
  late MockWalletBloc walletBloc;

  setUp(() {
    repository = MockWalletRepository();
    walletBloc = MockWalletBloc();
    whenListen(
      walletBloc,
      const Stream<WalletState>.empty(),
      initialState: const WalletState().withSnapshot(
        snapshot(),
        isFromCache: false,
        status: WalletStatus.ready,
      ),
    );
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    RepositoryProvider<WalletRepository>.value(
      value: repository,
      child: BlocProvider<WalletBloc>.value(
        value: walletBloc,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SendMoneyPage(),
        ),
      ),
    ),
  );

  Future<void> fill(WidgetTester tester, {String amount = '5000'}) async {
    await tester.enterText(
      find.byKey(const Key('transfer_recipientName')),
      'Ada Obi',
    );
    await tester.enterText(
      find.byKey(const Key('transfer_accountNumber')),
      '0123456789',
    );
    await tester.enterText(find.byKey(const Key('transfer_amount')), amount);
    await tester.pump();
  }

  testWidgets('shows inline errors and no confirmation for an invalid form', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(
      find.byKey(const Key('transfer_accountNumber')),
      '12345',
    );
    await tester.tap(find.byKey(const Key('transfer_continue')));
    await tester.pumpAndSettle();

    expect(find.text("Enter the recipient's name"), findsOneWidget);
    expect(find.text('Account number must be 10 digits'), findsOneWidget);
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Confirm transfer'), findsNothing);
  });

  testWidgets('confirm -> submitting (locked) -> success, sent exactly once', (
    tester,
  ) async {
    final pending = Completer<Result<TransferReceipt>>();
    when(() => repository.sendMoney(any())).thenAnswer((_) => pending.future);
    await pump(tester);
    await fill(tester);

    await tester.tap(find.byKey(const Key('transfer_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm transfer'), findsOneWidget);
    expect(find.text('₦5,000.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('transfer_confirm')));
    // The spinner animates forever while submitting, so pump for a fixed
    // time (long enough for the sheet to close) instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // While submitting, the button is disabled, so hammering it does nothing.
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('transfer_continue')),
    );
    expect(button.onPressed, isNull);
    await tester.tap(find.byKey(const Key('transfer_continue')));

    pending.complete(Ok(receipt()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transfer_success')), findsOneWidget);
    expect(find.textContaining('New balance'), findsOneWidget);
    verify(() => repository.sendMoney(any())).called(1);
  });

  testWidgets('insufficient funds keeps the form and shows the error', (
    tester,
  ) async {
    when(() => repository.sendMoney(any()))
        .thenAnswer((_) async => const Err(InsufficientFundsFailure()));
    await pump(tester);
    await fill(tester, amount: '999999');

    await tester.tap(find.byKey(const Key('transfer_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transfer_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transfer_failure')), findsOneWidget);
    expect(find.text(const InsufficientFundsFailure().message), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
