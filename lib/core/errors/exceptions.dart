
class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}


class ParsingException implements Exception {
  final String message;
  ParsingException(this.message);
}