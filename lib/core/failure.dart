sealed class ApiFailure implements Exception {
  const ApiFailure();
}

final class NetworkFailure extends ApiFailure {
  const NetworkFailure();
}

final class ValidationFailure extends ApiFailure {
  const ValidationFailure(this.message);
  final String message;
}

final class NotFoundFailure extends ApiFailure {
  const NotFoundFailure();
}

final class ServerFailure extends ApiFailure {
  const ServerFailure();
}
