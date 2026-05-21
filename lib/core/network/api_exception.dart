class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final Object? originalError;

  factory ApiException.fromDio(dynamic error) {
    if (error is Exception) {
      return ApiException(message: error.toString(), originalError: error);
    }
    return ApiException(message: 'An unexpected error occurred', originalError: error);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
