import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tm30_pay/features/auth/domain/auth_session.dart';
import 'package:tm30_pay/features/auth/domain/auth_user.dart';

/// Keeps the session (tokens and profile) in the iOS Keychain or the Android
/// Keystore through flutter_secure_storage. Tokens are never written to
/// shared preferences.
class SessionStorage {
  SessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_session';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, Object?>;
      final user = json['user']! as Map<String, Object?>;
      return AuthSession(
        accessToken: json['accessToken']! as String,
        refreshToken: json['refreshToken']! as String,
        expiresAt: DateTime.parse(json['expiresAt']! as String),
        user: AuthUser(
          email: user['email']! as String,
          fullName: user['fullName']! as String,
          walletAccountNumber: user['walletAccountNumber']! as String,
          memberSince: DateTime.parse(user['memberSince']! as String),
        ),
      );
    } catch (_) {
      // If the Keychain or Keystore can't be read (for example after a
      // backup restore on Android), treat the user as signed out rather than
      // crashing at startup.
      await delete();
      return null;
    }
  }

  Future<void> write(AuthSession session) => _storage.write(
    key: _key,
    value: jsonEncode({
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'expiresAt': session.expiresAt.toIso8601String(),
      'user': {
        'email': session.user.email,
        'fullName': session.user.fullName,
        'walletAccountNumber': session.user.walletAccountNumber,
        'memberSince': session.user.memberSince.toIso8601String(),
      },
    }),
  );

  Future<void> delete() => _storage.delete(key: _key);
}
