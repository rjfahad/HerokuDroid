/// Endpoints and identifiers for the in-app updater.
class UpdateConstants {
  UpdateConstants._();

  /// Plain-text update manifest published from the repository root
  /// (`version.txt` on the default branch).
  static const String manifestUrl =
      'https://raw.githubusercontent.com/rjfahad/HerokuDroid/main/version.txt';

  /// Used when the manifest does not provide an explicit download URL.
  static const String releasesPage =
      'https://github.com/rjfahad/HerokuDroid/releases/latest';

  static const Duration timeout = Duration(seconds: 10);
}
