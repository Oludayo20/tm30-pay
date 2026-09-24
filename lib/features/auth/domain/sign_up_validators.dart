enum PhoneError { empty, invalid }

enum CodeError { incomplete }

enum UsernameError { empty, tooShort, invalid }

enum NameError { empty, invalid }

enum BirthDateError { empty, invalid, tooYoung }

/// Pure functions for the sign-up steps, like [CredentialValidators]. Each
/// returns null when the input is valid.
abstract final class SignUpValidators {
  static const int codeLength = 4;
  static const int minUsernameLength = 3;

  /// Opening a wallet needs an adult account holder.
  static const int minimumAge = 18;

  /// The format of the date of birth field. The field inserts the dashes
  /// as the user types.
  static const String birthDatePattern = 'dd-mm-yyyy';

  static final RegExp _phone = RegExp(r'^\+?\d{7,15}$');
  static final RegExp _username = RegExp(r'^[A-Za-z0-9_.]+$');
  // Letters from any alphabet, with spaces, hyphens and apostrophes inside
  // names such as "Mary-Jane" or "O'Neil".
  static final RegExp _name = RegExp(r"^\p{L}[\p{L}\p{M}' -]*$", unicode: true);
  static final RegExp _birthDate = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');

  /// Spaces, dashes and brackets are allowed while typing; the digits (with
  /// an optional leading "+") must make an E.164-length number.
  static PhoneError? phone(String value) {
    final compact = normalisePhone(value);
    if (compact.isEmpty) return PhoneError.empty;
    if (!_phone.hasMatch(compact)) return PhoneError.invalid;
    return null;
  }

  static String normalisePhone(String value) =>
      value.replaceAll(RegExp(r'[\s\-()]'), '');

  static CodeError? code(String value) =>
      RegExp('^\\d{$codeLength}\$').hasMatch(value)
      ? null
      : CodeError.incomplete;

  static UsernameError? username(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return UsernameError.empty;
    if (trimmed.length < minUsernameLength) return UsernameError.tooShort;
    if (!_username.hasMatch(trimmed)) return UsernameError.invalid;
    return null;
  }

  static NameError? name(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return NameError.empty;
    if (!_name.hasMatch(trimmed)) return NameError.invalid;
    return null;
  }

  static BirthDateError? birthDate(String value, {required DateTime today}) {
    if (value.trim().isEmpty) return BirthDateError.empty;
    final date = parseBirthDate(value);
    if (date == null || date.isAfter(today) || date.year < 1900) {
      return BirthDateError.invalid;
    }
    final eighteenth = DateTime(date.year + minimumAge, date.month, date.day);
    if (eighteenth.isAfter(today)) return BirthDateError.tooYoung;
    return null;
  }

  /// Parses "dd-mm-yyyy", rejecting dates that don't exist such as
  /// 31-02-2000 (DateTime would silently roll that over to March).
  static DateTime? parseBirthDate(String value) {
    final match = _birthDate.firstMatch(value.trim());
    if (match == null) return null;
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
