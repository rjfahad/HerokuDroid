/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// App name
  static const String appName = 'HerokuDroid';

  /// Secure storage keys
  static const String tokenKey = 'heroku_api_token';

  /// App version
  static const String version = '1.0.0';

  /// GitHub repository (for support/feedback)
  static const String githubUrl =
      'https://github.com/yourusername/herokuandroid';

  /// Default error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String timeoutErrorMessage =
      'Request timed out. Please try again.';
  static const String unauthorizedErrorMessage =
      'Invalid or expired token. Please log in again.';

  /// Pagination
  static const int defaultPageSize = 20;

  /// Log settings
  static const int defaultLogTailLines = 100;
  static const int maxLogLines = 1000;
}
