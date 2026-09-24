import 'dart:developer' as developer;

import 'exceptions.dart';
import 'failure.dart';
import 'result.dart';

/// Runs [body] and wraps the outcome in a [Result]. This is the one place
/// where data-layer exceptions are turned into [Failure]s.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on DataException catch (e) {
    return Err(switch (e) {
      NetworkException() => const NetworkFailure(),
      InsufficientFundsException() => const InsufficientFundsFailure(),
      NotFoundException() => const NotFoundFailure(),
      UnauthorizedException() => const InvalidCredentialsFailure(),
      InvalidOtpException() => const InvalidOtpFailure(),
    });
  } catch (e, st) {
    // In production this would go to Crashlytics or Sentry.
    developer.log('Unexpected error', error: e, stackTrace: st, name: 'guard');
    return const Err(UnexpectedFailure());
  }
}
