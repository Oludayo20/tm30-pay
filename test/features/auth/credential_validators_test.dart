import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/features/auth/domain/credential_validators.dart';

void main() {
  group('email', () {
    test('accepts valid addresses', () {
      expect(CredentialValidators.email('ada@tm30.net'), isNull);
      expect(CredentialValidators.email('  a.b+c@sub.example.io '), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(CredentialValidators.email(''), EmailError.empty);
      expect(CredentialValidators.email('   '), EmailError.empty);
      for (final bad in ['ada', 'ada@', '@tm30.net', 'ada@tm30', 'a da@x.io']) {
        expect(
          CredentialValidators.email(bad),
          EmailError.invalid,
          reason: bad,
        );
      }
    });
  });

  group('password', () {
    test('requires 8 or more characters', () {
      expect(CredentialValidators.password(''), PasswordError.empty);
      expect(CredentialValidators.password('1234567'), PasswordError.tooShort);
      expect(CredentialValidators.password('12345678'), isNull);
    });
  });
}
