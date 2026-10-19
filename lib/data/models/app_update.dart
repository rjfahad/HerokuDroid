import 'package:herokudroid/core/utils/version_utils.dart';

/// A release advertised by the remote update manifest.
class AppUpdate {
  const AppUpdate({required this.version, this.downloadUrl, this.notes});

  /// Latest published version, e.g. `1.2.0`.
  final String version;

  /// Optional URL the "Update" action should open (APK or release page).
  final String? downloadUrl;

  /// Optional release notes shown in the dialog.
  final String? notes;

  /// Parse the plain-text update manifest.
  ///
  /// Blank lines and lines starting with `#` are ignored. The first remaining
  /// line is the version; an optional following `http(s)://` line is the
  /// download URL; every remaining line is treated as release notes.
  ///
  /// Returns null when no version line is present.
  static AppUpdate? parse(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();

    if (lines.isEmpty) return null;

    final version = lines.first;
    String? downloadUrl;
    var notesStart = 1;

    if (lines.length > 1 && _looksLikeUrl(lines[1])) {
      downloadUrl = lines[1];
      notesStart = 2;
    }

    final notes = lines.length > notesStart
        ? lines.sublist(notesStart).join('\n')
        : null;

    return AppUpdate(version: version, downloadUrl: downloadUrl, notes: notes);
  }

  /// Whether this release is newer than [currentVersion].
  bool isNewerThan(String currentVersion) =>
      isNewerVersion(version, currentVersion);

  static bool _looksLikeUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');
}
