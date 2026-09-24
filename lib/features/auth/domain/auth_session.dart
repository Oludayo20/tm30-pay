import 'package:equatable/equatable.dart';

import 'auth_user.dart';

/// The tokens and profile of a signed-in user. Refresh token and expiry are
/// modelled now, even though the fake backend never expires tokens, so
/// adding token refresh later does not change the storage format. See the
/// README.
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final AuthUser user;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, user];
}
