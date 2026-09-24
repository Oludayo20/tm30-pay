part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  const AuthState(this.user);

  /// Null when nobody is signed in.
  final AuthUser? user;

  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [user];
}
