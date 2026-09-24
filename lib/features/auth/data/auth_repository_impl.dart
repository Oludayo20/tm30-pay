import 'dart:async';

import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/sign_up_details.dart';
import 'fake_auth_api.dart';
import 'profile_photo_store.dart';
import 'session_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._api,
    required this._storage,
    required this._photos,
  });

  final FakeAuthApi _api;
  final SessionStorage _storage;
  final ProfilePhotoStore _photos;
  final _users = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get userChanges => _users.stream;

  @override
  Future<AuthUser?> currentUser() async {
    // An expired session still counts as signed in. With a real backend,
    // the HTTP client would use the refresh token when it gets a 401,
    // instead of forcing the user to sign in again.
    final session = await _storage.read();
    final user = session?.user;
    if (user?.photoPath == null) return user;
    return user!.copyWith(photoPath: await _photos.resolve(user.photoPath));
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
  Future<Result<void>> requestOtp({required String phone}) =>
      guard(() => _api.requestOtp(phone: phone));

  @override
  Future<Result<void>> verifyOtp({
    required String phone,
    required String code,
  }) => guard(() => _api.verifyOtp(phone: phone, code: code));

  @override
  Future<Result<void>> signUp(SignUpDetails details) async {
    final result = await guard(() async {
      final photo = details.photoPath;
      final session = await _api.signUp(
        SignUpDetails(
          email: details.email.trim(),
          password: details.password,
          phone: details.phone,
          username: details.username.trim(),
          firstName: details.firstName.trim(),
          lastName: details.lastName.trim(),
          dateOfBirth: details.dateOfBirth,
          photoPath: photo == null ? null : await _photos.save(photo),
        ),
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
    final session = await _storage.read();
    await _storage.delete();
    // The photo belongs to this account, so don't leave it on the device.
    await _photos.delete(await _photos.resolve(session?.user.photoPath));
    _users.add(null);
  }

  void dispose() => _users.close();
}
