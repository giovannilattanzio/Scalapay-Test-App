/// Base class for every error surfaced by the domain layer.
abstract class Failure {
  const Failure({required this.message, required this.code});

  final String message;
  final int code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code = 500});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code = 0});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code = -1});
}

class SerializationFailure extends Failure {
  const SerializationFailure({required super.message, super.code = -2});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code = 404});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code = -99});
}
