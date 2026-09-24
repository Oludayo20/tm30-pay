import 'dart:async';

import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'fake_auth_api.dart';
import 'session_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._api, required this._storage});

  final FakeAuthApi _api;
  final SessionStorage _storage;
  final _users = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get userChanges => _users.stream;

  @override
  Future<AuthUser?> currentUser() async {
    // An expired session still counts as signed in. With a real backend,
    // the HTTP client would use the refresh token when it gets a 401,
    // instead of forcing the user to sign in again.
    final session = await _storage.read();
    return session?.user;
  }

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await guard(() async {
      final session = await _api.signIn(
        email: email.trim(),
        password: password,
      );
      await _storage.write(session);
      return session.user;
    });
    switch (result) {
      case Ok(value: final user):
        _users.add(user);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<void> signOut() async {
    await _storage.delete();
    _users.add(null);
  }

  void dispose() => _users.close();
}
