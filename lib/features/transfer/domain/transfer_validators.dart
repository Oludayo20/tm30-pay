import 'package:tm30_pay/core/utils/money.dart';

enum RecipientNameError { empty, tooShort, invalidCharacters }

enum AccountNumberError { empty, notTenDigits }

enum AmountError { empty, invalid, zero, aboveLimit }

enum NoteError { tooLong }

/// Business rules for the transfer form. Each validator returns null when
/// the input is valid.
///
/// There is no balance check here on purpose. The balance on screen may be
/// cached and out of date, so the server makes the final decision and
/// rejects the transfer with an "insufficient funds" error.
abstract final class TransferValidators {
  static const int accountNumberLength = 10;
  static const int maxNoteLength = 100;

  /// A per-transfer limit, as most Nigerian wallets have (₦5,000,000).
  static const int maxAmount = 5000000 * Money.minorUnitsPerMajor;

  static final RegExp _name = RegExp(r"^[A-Za-z][A-Za-z .'-]*$");
  static final RegExp _tenDigits = RegExp(r'^\d{10}$');

  static RecipientNameError? recipientName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return RecipientNameError.empty;
    if (trimmed.length < 2) return RecipientNameError.tooShort;
    if (!_name.hasMatch(trimmed)) return RecipientNameError.invalidCharacters;
    return null;
  }

  static AccountNumberError? accountNumber(String value) {
    if (value.isEmpty) return AccountNumberError.empty;
    if (!_tenDigits.hasMatch(value)) return AccountNumberError.notTenDigits;
    return null;
  }

  static AmountError? amount(String value) {
    if (value.trim().isEmpty) return AmountError.empty;
    final minor = Money.tryParse(value);
    if (minor == null) return AmountError.invalid;
    if (minor == 0) return AmountError.zero;
    if (minor > maxAmount) return AmountError.aboveLimit;
    return null;
  }

  static NoteError? note(String value) =>
      value.trim().length > maxNoteLength ? NoteError.tooLong : null;
}
