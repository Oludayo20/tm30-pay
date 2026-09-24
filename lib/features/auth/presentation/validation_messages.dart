// The domain returns error enums; these extensions turn them into the text
// shown on screen. Localisation would replace the strings here.

import 'package:tm30_pay/features/auth/domain/credential_validators.dart';
import 'package:tm30_pay/features/auth/domain/sign_up_validators.dart';

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

extension PhoneErrorText on PhoneError {
  String get message => switch (this) {
    PhoneError.empty => 'Enter your mobile number',
    PhoneError.invalid => 'Enter a valid number, including the country code',
  };
}

extension UsernameErrorText on UsernameError {
  String get message => switch (this) {
    UsernameError.empty => 'Choose a username',
    UsernameError.tooShort =>
      'Use at least ${SignUpValidators.minUsernameLength} characters',
    UsernameError.invalid => 'Use only letters, numbers, dots and underscores',
  };
}

extension NameErrorText on NameError {
  String message(String field) => switch (this) {
    NameError.empty => 'Enter your $field',
    NameError.invalid => 'Use letters only',
  };
}

extension BirthDateErrorText on BirthDateError {
  String get message => switch (this) {
    BirthDateError.empty => 'Enter your date of birth',
    BirthDateError.invalid => 'Enter a real date as dd-mm-yyyy',
    BirthDateError.tooYoung =>
      'You must be ${SignUpValidators.minimumAge} or older to open a wallet',
  };
}
