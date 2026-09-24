import '../../../core/error/result.dart';
import 'auth_user.dart';
import 'sign_up_details.dart';

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

  /// Sends a one-time code by SMS to [phone].
  Future<Result<void>> requestOtp({required String phone});

  /// Checks the code the user typed. Fails with InvalidOtpFailure when it
  /// doesn't match.
  Future<Result<void>> verifyOtp({required String phone, required String code});

  /// Creates the account and signs the new user in. Like [signIn], success
  /// is announced on [userChanges], which moves the router to the wallet.
  Future<Result<void>> signUp(SignUpDetails details);

  Future<void> signOut();
}
