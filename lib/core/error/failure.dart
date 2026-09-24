import 'package:equatable/equatable.dart';

/// Typed, UI-safe errors. The data layer turns every exception into one of
/// these, so widgets and blocs never see raw exceptions.
///
/// The class is sealed so a `switch` over a failure must handle every case.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// A message you can show to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// The request never reached the server, or the response never came back.
/// Usually worth retrying.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

final class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([
    super.message = 'Insufficient funds. Enter a smaller amount.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that item.']);
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Incorrect email or password.',
  ]);
}

/// Anything we did not expect. Log it and show a generic message.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
