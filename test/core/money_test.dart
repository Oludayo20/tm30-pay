import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/core/utils/money.dart';

void main() {
  group('Money.tryParse', () {
    test('parses whole and fractional amounts into kobo', () {
      expect(Money.tryParse('1500'), 150000);
      expect(Money.tryParse('1,500.5'), 150050);
      expect(Money.tryParse('0.07'), 7);
      expect(Money.tryParse(' 250,000.00 '), 25000000);
    });

    test('rejects malformed input rather than guessing', () {
      for (final input in ['', '.', '1.234', '1..2', 'abc', '-5', '1e3']) {
        expect(Money.tryParse(input), isNull, reason: input);
      }
    });
  });

  test('Money.format renders naira with two decimals', () {
    expect(Money.format(25000000), '₦250,000.00');
  });
}
