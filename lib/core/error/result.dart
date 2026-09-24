import 'failure.dart';

/// Every repository method returns a [Result] instead of throwing, so the
/// possible failures are part of the method's type and callers must handle
/// them.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
