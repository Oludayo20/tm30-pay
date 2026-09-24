import 'package:equatable/equatable.dart';

/// Everything collected across the sign-up steps, sent to the backend in
/// one call once the profile is complete.
class SignUpDetails extends Equatable {
  const SignUpDetails({
    required this.email,
    required this.password,
    required this.phone,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.photoPath,
  });

  final String email;
  final String password;

  /// Verified with a one-time code before this is sent.
  final String phone;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;

  /// A local file chosen by the user, if any.
  final String? photoPath;

  @override
  List<Object?> get props => [
    email,
    password,
    phone,
    username,
    firstName,
    lastName,
    dateOfBirth,
    photoPath,
  ];
}
