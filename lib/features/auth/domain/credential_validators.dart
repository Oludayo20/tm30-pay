enum EmailError { empty, invalid }

enum PasswordError { empty, tooShort }

/// Pure functions, so they are trivial to unit test. Each returns null when
/// the input is valid.
abstract final class CredentialValidators {
  static const int minPasswordLength = 8;

  // Deliberately simple: one "@", a dot in the domain, and no spaces. The
  // server makes the final decision on whether an email is valid.
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static EmailError? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return EmailError.empty;
    if (!_email.hasMatch(trimmed)) return EmailError.invalid;
    return null;
  }

  static PasswordError? password(String value) {
    if (value.isEmpty) return PasswordError.empty;
    if (value.length < minPasswordLength) return PasswordError.tooShort;
    return null;
  }
}
