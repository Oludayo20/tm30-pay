import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/features/auth/domain/credential_validators.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  blocTest<SignInBloc, SignInState>(
    'invalid credentials reveal errors without calling the repository',
    build: () => SignInBloc(authRepository: repository),
    act: (bloc) => bloc
      ..add(const SignInEmailChanged('not-an-email'))
      ..add(const SignInPasswordChanged('short'))
      ..add(const SignInSubmitted()),
    verify: (bloc) {
      expect(bloc.state.visibleEmailError, EmailError.invalid);
      expect(bloc.state.visiblePasswordError, PasswordError.tooShort);
      verifyNever(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  blocTest<SignInBloc, SignInState>(
    'errors stay hidden until the field is blurred',
    build: () => SignInBloc(authRepository: repository),
    act: (bloc) => bloc.add(const SignInEmailChanged('a')),
    verify: (bloc) => expect(bloc.state.visibleEmailError, isNull),
  );

  final signIn = Completer<Result<void>>();
  blocTest<SignInBloc, SignInState>(
    'valid credentials sign in exactly once despite a double tap',
    setUp: () => when(
      () => repository.signIn(email: 'ada@tm30.net', password: 'password1'),
    ).thenAnswer((_) => signIn.future),
    build: () => SignInBloc(authRepository: repository),
    act: (bloc) async {
      bloc
        ..add(const SignInEmailChanged('ada@tm30.net'))
        ..add(const SignInPasswordChanged('password1'))
        ..add(const SignInSubmitted())
        ..add(const SignInSubmitted());
      await Future<void>.delayed(Duration.zero);
      signIn.complete(const Ok(null));
      await Future<void>.delayed(Duration.zero);
      // A tap after success must not sign in again.
      bloc.add(const SignInSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.status, SignInStatus.success);
      verify(
        () => repository.signIn(email: 'ada@tm30.net', password: 'password1'),
      ).called(1);
    },
  );
}
