import 'package:equatable/equatable.dart';

/// The profile of the signed-in user, as returned by the backend at sign-in.
class AuthUser extends Equatable {
  const AuthUser({
    required this.email,
    required this.fullName,
    required this.walletAccountNumber,
    required this.memberSince,
  });

  final String email;
  final String fullName;

  /// The 10-digit number other people send money to.
  final String walletAccountNumber;
  final DateTime memberSince;

  String get firstName => fullName.split(' ').first;

  /// Up to two initials for the avatar, e.g. "Ada Obi" becomes "AO".
  String get initials {
    final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final letters = parts.length == 1
        ? parts.first.substring(0, 1)
        : '${parts.first[0]}${parts.last[0]}';
    return letters.toUpperCase();
  }

  @override
  List<Object?> get props => [
    email,
    fullName,
    walletAccountNumber,
    memberSince,
  ];
}
