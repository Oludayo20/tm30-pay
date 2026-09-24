import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/features/auth/domain/auth_repository.dart';
import 'package:tm30_pay/features/auth/presentation/pages/sign_in_page.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    RepositoryProvider<AuthRepository>.value(
      value: repository,
      child: const MaterialApp(home: SignInPage()),
    ),
  );

  testWidgets('submitting an empty form shows inline errors', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('signIn_submit')));
    await tester.pump();

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('valid credentials call the repository', (tester) async {
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(null));
    await pump(tester);

    await tester.enterText(
      find.byKey(const Key('signIn_email')),
      'ada@tm30.net',
    );
    await tester.enterText(
      find.byKey(const Key('signIn_password')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('signIn_submit')));
    await tester.pumpAndSettle();

    verify(
      () => repository.signIn(email: 'ada@tm30.net', password: 'password1'),
    ).called(1);
  });
}
