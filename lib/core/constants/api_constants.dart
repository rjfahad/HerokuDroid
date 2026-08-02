/// API Constants for Heroku Platform API
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Base URL for Heroku Platform API
  static const String baseUrl = 'https://api.heroku.com';

  /// API Version Header
  static const String acceptHeader = 'application/vnd.heroku+json; version=3';

  /// Content Type Header
  static const String contentTypeHeader = 'application/json';

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // API Endpoints
  /// Get all apps
  static const String apps = '/apps';

  /// Get specific app by ID or name
  static String app(String appId) => '/apps/$appId';

  /// Delete specific app
  static String deleteApp(String appId) => '/apps/$appId';

  /// Get dynos for an app
  static String dynos(String appId) => '/apps/$appId/dynos';

  /// Get specific dyno
  static String dyno(String appId, String dynoId) =>
      '/apps/$appId/dynos/$dynoId';

  /// Restart all dynos
  static String restartDynos(String appId) => '/apps/$appId/dynos';

  /// Get formation for an app
  static String formation(String appId) => '/apps/$appId/formation';

  /// Scale specific formation
  static String formationType(String appId, String type) =>
      '/apps/$appId/formation/$type';

  /// Get config vars
  static String configVars(String appId) => '/apps/$appId/config-vars';

  /// Get add-ons
  static String addons(String appId) => '/apps/$appId/addons';

  /// Get specific add-on
  static String addon(String appId, String addonId) =>
      '/apps/$appId/addons/$addonId';

  /// Get releases
  static String releases(String appId) => '/apps/$appId/releases';

  /// Create log session
  static String logSessions(String appId) => '/apps/$appId/log-sessions';
}
