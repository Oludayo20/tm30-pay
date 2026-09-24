import '../../../core/utils/money.dart';
import '../domain/transfer_validators.dart';

extension RecipientNameErrorText on RecipientNameError {
  String get message => switch (this) {
    RecipientNameError.empty => "Enter the recipient's name",
    RecipientNameError.tooShort => 'Name is too short',
    RecipientNameError.invalidCharacters =>
      'Use letters, spaces, hyphens or apostrophes only',
  };
}

extension AccountNumberErrorText on AccountNumberError {
  String get message => switch (this) {
    AccountNumberError.empty => 'Enter the account number',
    AccountNumberError.notTenDigits => 'Account number must be 10 digits',
  };
}

extension AmountErrorText on AmountError {
  String get message => switch (this) {
    AmountError.empty => 'Enter an amount',
    AmountError.invalid => 'Enter a valid amount, e.g. 1500 or 1500.50',
    AmountError.zero => 'Amount must be more than ₦0',
    AmountError.aboveLimit =>
      'Maximum per transfer is ${Money.format(TransferValidators.maxAmount)}',
  };
}

extension NoteErrorText on NoteError {
  String get message => switch (this) {
    NoteError.tooLong =>
      'Note must be ${TransferValidators.maxNoteLength} characters or fewer',
  };
}
