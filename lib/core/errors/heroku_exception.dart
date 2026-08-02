import 'package:dio/dio.dart';

/// Custom exception for Heroku API errors
class HerokuException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  HerokuException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  /// Create exception from DioException
  factory HerokuException.fromDioException(DioException error) {
    String message;
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Server took too long to respond.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate. SSL/TLS error.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        message = _getErrorMessageFromResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred. Please try again.';
        break;
    }

    return HerokuException(
      message: message,
      statusCode: statusCode,
      originalError: error,
      stackTrace: error.stackTrace,
    );
  }

  /// Extract error message from HTTP response
  static String _getErrorMessageFromResponse(Response? response) {
    if (response == null) {
      return 'Unknown server error occurred.';
    }

    final statusCode = response.statusCode;

    // Try to get message from response data
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
      if (data.containsKey('id') && data['id'] == 'unauthorized') {
        return 'Invalid or expired API token. Please log in again.';
      }
    }

    // Default messages based on status code
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Invalid or expired API token.';
      case 403:
        return 'Forbidden. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Rate limit exceeded. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Server error (${statusCode ?? 'unknown'}). Please try again.';
    }
  }

  /// Check if exception is due to authentication error
  bool get isAuthError => statusCode == 401;

  /// Check if exception is due to network error
  bool get isNetworkError {
    return originalError is DioException &&
        (originalError as DioException).type ==
            DioExceptionType.connectionError;
  }

  @override
  String toString() {
    return 'HerokuException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Exception for authentication-related errors
class AuthenticationException extends HerokuException {
  AuthenticationException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  factory AuthenticationException.invalidToken() {
    return AuthenticationException(
      message: 'Invalid API token. Please check and try again.',
      statusCode: 401,
    );
  }

  factory AuthenticationException.tokenExpired() {
    return AuthenticationException(
      message: 'API token has expired. Please log in again.',
      statusCode: 401,
    );
  }

  factory AuthenticationException.noToken() {
    return AuthenticationException(
      message: 'No API token found. Please log in.',
    );
  }
}

/// Exception for validation errors
class ValidationException extends HerokuException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    this.errors,
    super.statusCode = 422,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.fromResponse(Response response) {
    Map<String, List<String>>? errors;
    String message = 'Validation failed.';

    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('errors')) {
        errors = (data['errors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      }
      if (data.containsKey('message')) {
        message = data['message'] as String;
      }
    }

    return ValidationException(
      message: message,
      errors: errors,
      originalError: response,
    );
  }

  /// Get all error messages as a single string
  String get allErrorMessages {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    final messages = errors!.entries
        .map((entry) {
          final field = entry.key;
          final fieldErrors = entry.value.join(', ');
          return '$field: $fieldErrors';
        })
        .join('\n');

    return messages;
  }
}
