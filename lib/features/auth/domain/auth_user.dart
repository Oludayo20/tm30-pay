import 'package:equatable/equatable.dart';

/// The profile of the signed-in user, as returned by the backend at sign-in.
class AuthUser extends Equatable {
  const AuthUser({
    required this.email,
    required this.fullName,
    required this.walletAccountNumber,
    required this.memberSince,
    this.username,
    this.photoPath,
  });

  final String email;
  final String fullName;

  /// The 10-digit number other people send money to.
  final String walletAccountNumber;
  final DateTime memberSince;

  /// Chosen at sign-up. Null for accounts that only ever signed in.
  final String? username;

  /// A profile photo stored on this device, if the user added one.
  final String? photoPath;

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

  AuthUser copyWith({String? photoPath}) => AuthUser(
    email: email,
    fullName: fullName,
    walletAccountNumber: walletAccountNumber,
    memberSince: memberSince,
    username: username,
    photoPath: photoPath ?? this.photoPath,
  );

  @override
  List<Object?> get props => [
    email,
    fullName,
    walletAccountNumber,
    memberSince,
    username,
    photoPath,
  ];
}
