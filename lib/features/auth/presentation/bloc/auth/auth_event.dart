part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Start listening to sign-in and sign-out changes from the repository.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
