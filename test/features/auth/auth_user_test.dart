import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/features/auth/data/fake_auth_api.dart';
import 'package:tm30_pay/features/auth/domain/auth_user.dart';

void main() {
  AuthUser user(String name) => AuthUser(
    email: 'a@b.co',
    fullName: name,
    walletAccountNumber: '3000000000',
    memberSince: DateTime(2024),
  );

  test('initials and first name come from the full name', () {
    expect(user('Ada Obi').initials, 'AO');
    expect(user('Ada Chioma Obi').initials, 'AO');
    expect(user('ada').initials, 'A');
    expect(user('Ada Obi').firstName, 'Ada');
  });

  test('fake API derives a readable name from the email', () {
    expect(FakeAuthApi.nameFromEmail('ada.obi@tm30.net'), 'Ada Obi');
    expect(FakeAuthApi.nameFromEmail('TUNDE_bakare99@x.io'), 'Tunde Bakare');
    expect(FakeAuthApi.nameFromEmail('123@x.io'), 'Tm30 User');
  });

  test('fake API gives each email a stable 10-digit account number', () {
    final a = FakeAuthApi.accountNumberFromEmail('ada@tm30.net');
    expect(a, matches(RegExp(r'^\d{10}$')));
    expect(FakeAuthApi.accountNumberFromEmail('ADA@tm30.net'), a);
    expect(FakeAuthApi.accountNumberFromEmail('bola@tm30.net'), isNot(a));
  });
}
