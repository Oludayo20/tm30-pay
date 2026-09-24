import 'dart:math';

import '../../../core/utils/fake_latency.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';

/// Accepts any credentials that pass client-side validation and returns a
/// made-up token pair and profile.
class FakeAuthApi {
  FakeAuthApi({this.latency = const FakeLatency(), Random? random})
    : _random = random ?? Random.secure();

  final FakeLatency latency;
  final Random _random;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await latency();
    final now = DateTime.now();
    return AuthSession(
      accessToken: 'fake-access-${_token()}',
      refreshToken: 'fake-refresh-${_token()}',
      expiresAt: now.add(const Duration(hours: 1)),
      user: AuthUser(
        email: email,
        fullName: nameFromEmail(email),
        walletAccountNumber: accountNumberFromEmail(email),
        memberSince: DateTime(2024, 3, 12),
      ),
    );
  }

  /// "ada.obi@tm30.net" becomes "Ada Obi". A real backend would return the
  /// name the user registered with.
  static String nameFromEmail(String email) {
    final local = email.split('@').first;
    final words = local
        .split(RegExp(r'[._\-+\d]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .toList();
    return words.isEmpty ? 'Tm30 User' : words.join(' ');
  }

  /// The same email always gets the same 10-digit account number. This uses
  /// its own hash because String.hashCode can differ between runs.
  static String accountNumberFromEmail(String email) {
    final hash = email.toLowerCase().codeUnits.fold<int>(
      17,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    final seeded = Random(hash);
    return '30${List.generate(8, (_) => seeded.nextInt(10)).join()}';
  }

  String _token() =>
      List.generate(24, (_) => _random.nextInt(16).toRadixString(16)).join();
}
