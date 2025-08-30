class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details = const {},
  });

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException(this.message, [this.originalError]);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> errors;

  ValidationException(this.message, [this.errors = const {}]);

  @override
  String toString() => 'ValidationException: $message';
}

class WebSocketException implements Exception {
  final String message;
  final dynamic originalError;

  WebSocketException(this.message, [this.originalError]);

  @override
  String toString() => 'WebSocketException: $message';
}
