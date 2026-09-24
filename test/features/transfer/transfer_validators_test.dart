import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/features/transfer/domain/transfer_validators.dart';

void main() {
  group('accountNumber', () {
    test('accepts exactly 10 digits', () {
      expect(TransferValidators.accountNumber('0123456789'), isNull);
    });

    test('rejects empty, short, long and non-numeric values', () {
      expect(TransferValidators.accountNumber(''), AccountNumberError.empty);
      for (final bad in [
        '012345678',
        '01234567890',
        '01234abc89',
        '0123 45678',
      ]) {
        expect(
          TransferValidators.accountNumber(bad),
          AccountNumberError.notTenDigits,
          reason: bad,
        );
      }
    });
  });

  group('amount', () {
    test('validates format, zero and the per-transfer limit', () {
      expect(TransferValidators.amount(''), AmountError.empty);
      expect(TransferValidators.amount('12.345'), AmountError.invalid);
      expect(TransferValidators.amount('0.00'), AmountError.zero);
      expect(TransferValidators.amount('5,000,000.01'), AmountError.aboveLimit);
      expect(TransferValidators.amount('5,000,000'), isNull);
      expect(TransferValidators.amount('0.01'), isNull);
    });
  });

  group('recipientName', () {
    test('accepts real-world names and rejects junk', () {
      expect(TransferValidators.recipientName("Ada O'Neil-Obi"), isNull);
      expect(TransferValidators.recipientName(' '), RecipientNameError.empty);
      expect(
        TransferValidators.recipientName('A'),
        RecipientNameError.tooShort,
      );
      expect(
        TransferValidators.recipientName('Ada123'),
        RecipientNameError.invalidCharacters,
      );
    });
  });

  test('note is optional but capped', () {
    expect(TransferValidators.note(''), isNull);
    expect(TransferValidators.note('a' * 101), NoteError.tooLong);
  });
}
