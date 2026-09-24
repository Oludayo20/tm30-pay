import '../domain/credential_validators.dart';

// The domain returns error enums; these extensions turn them into the text
// shown on screen. Localisation would replace the strings here.

extension EmailErrorText on EmailError {
  String get message => switch (this) {
    EmailError.empty => 'Enter your email address',
    EmailError.invalid => 'Enter a valid email address',
  };
}

extension PasswordErrorText on PasswordError {
  String get message => switch (this) {
    PasswordError.empty => 'Enter your password',
    PasswordError.tooShort =>
      'Password must be at least ${CredentialValidators.minPasswordLength} characters',
  };
}
