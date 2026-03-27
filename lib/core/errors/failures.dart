
abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server error"]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "Cache error"]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "No internet"]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = "Not found"]);
}