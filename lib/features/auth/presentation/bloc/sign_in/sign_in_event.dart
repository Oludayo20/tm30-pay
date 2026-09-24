part of 'sign_in_bloc.dart';

enum SignInField { email, password }

sealed class SignInEvent {
  const SignInEvent();
}

final class SignInEmailChanged extends SignInEvent {
  const SignInEmailChanged(this.email);
  final String email;
}

final class SignInPasswordChanged extends SignInEvent {
  const SignInPasswordChanged(this.password);
  final String password;
}

/// A field lost focus. From then on its errors are shown.
final class SignInFieldBlurred extends SignInEvent {
  const SignInFieldBlurred(this.field);
  final SignInField field;
}

final class SignInSubmitted extends SignInEvent {
  const SignInSubmitted();
}
