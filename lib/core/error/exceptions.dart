/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Location exception
class LocationException extends AppException {
  const LocationException({
    super.message = 'Location error occurred',
    super.code,
  });
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.code,
  });
}

