class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred'])
      : super(message, code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed'])
      : super(message, code: 'AUTH_ERROR');
}

class DatabaseException extends AppException {
  const DatabaseException([String message = 'Database operation failed'])
      : super(message, code: 'DB_ERROR');
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, code: 'NOT_FOUND');
}

class ValidationException extends AppException {
  const ValidationException([String message = 'Validation failed'])
      : super(message, code: 'VALIDATION_ERROR');
}
