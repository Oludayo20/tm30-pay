import '../../../core/error/result.dart';
import 'auth_user.dart';

abstract interface class AuthRepository {
  /// The signed-in user saved in secure storage, or null if nobody is signed
  /// in. The app calls this once at startup, before the first frame, so the
  /// router knows whether to show sign-in.
  Future<AuthUser?> currentUser();

  /// Emits the user after every sign-in, and null after every sign-out.
  Stream<AuthUser?> get userChanges;

  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
