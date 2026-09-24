part of 'sign_up_bloc.dart';

sealed class SignUpEvent {
  const SignUpEvent();
}

/// The user chose "Sign up" on the welcome screen. Clears any earlier,
/// abandoned attempt.
final class SignUpStarted extends SignUpEvent {
  const SignUpStarted();
}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);
  final String email;
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);
  final String password;
}

/// A field lost focus. From then on its errors are shown.
final class SignUpFieldBlurred extends SignUpEvent {
  const SignUpFieldBlurred(this.field);
  final SignUpField field;
}

final class SignUpCredentialsSubmitted extends SignUpEvent {
  const SignUpCredentialsSubmitted();
}

final class SignUpPhoneChanged extends SignUpEvent {
  const SignUpPhoneChanged(this.phone);
  final String phone;
}

/// "Get OTP" on the phone step.
final class SignUpCodeRequested extends SignUpEvent {
  const SignUpCodeRequested();
}

/// "Resend OTP" on the verification step.
final class SignUpCodeResent extends SignUpEvent {
  const SignUpCodeResent();
}

final class SignUpCodeChanged extends SignUpEvent {
  const SignUpCodeChanged(this.code);
  final String code;
}

final class SignUpCodeSubmitted extends SignUpEvent {
  const SignUpCodeSubmitted();
}

final class SignUpUsernameChanged extends SignUpEvent {
  const SignUpUsernameChanged(this.username);
  final String username;
}

final class SignUpFirstNameChanged extends SignUpEvent {
  const SignUpFirstNameChanged(this.firstName);
  final String firstName;
}

final class SignUpLastNameChanged extends SignUpEvent {
  const SignUpLastNameChanged(this.lastName);
  final String lastName;
}

final class SignUpBirthDateChanged extends SignUpEvent {
  const SignUpBirthDateChanged(this.birthDate);
  final String birthDate;
}

/// A new profile photo, or null to remove it.
final class SignUpPhotoChanged extends SignUpEvent {
  const SignUpPhotoChanged(this.photoPath);
  final String? photoPath;
}

final class SignUpProfileSubmitted extends SignUpEvent {
  const SignUpProfileSubmitted();
}
