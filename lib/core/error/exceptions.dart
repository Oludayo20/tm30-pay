/// Exceptions thrown by data sources, such as an HTTP client or the fake
/// backend. They never leave the data layer: [guard] turns them into
/// failures before a repository returns.
sealed class DataException implements Exception {
  const DataException([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

final class NetworkException extends DataException {
  const NetworkException([super.message]);
}

final class InsufficientFundsException extends DataException {
  const InsufficientFundsException([super.message]);
}

final class NotFoundException extends DataException {
  const NotFoundException([super.message]);
}

final class UnauthorizedException extends DataException {
  const UnauthorizedException([super.message]);
}
