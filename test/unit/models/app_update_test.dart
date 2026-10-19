import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/models/app_update.dart';

void main() {
  group('AppUpdate.parse', () {
    test('parses version, download URL and notes', () {
      final update = AppUpdate.parse(
        '1.2.0\n'
        'https://example.com/app.apk\n'
        'Faster log streaming\n'
        'Bug fixes',
      );

      expect(update, isNotNull);
      expect(update!.version, '1.2.0');
      expect(update.downloadUrl, 'https://example.com/app.apk');
      expect(update.notes, 'Faster log streaming\nBug fixes');
    });

    test('ignores blank lines and comments', () {
      final update = AppUpdate.parse(
        '# manifest\n'
        '\n'
        'v1.3.0\n'
        '# a comment\n'
        'https://example.com/app.apk\n',
      );

      expect(update!.version, 'v1.3.0');
      expect(update.downloadUrl, 'https://example.com/app.apk');
      expect(update.notes, isNull);
    });

    test('works without a download URL', () {
      final update = AppUpdate.parse('1.4.0\nJust notes here');

      expect(update!.downloadUrl, isNull);
      expect(update.notes, 'Just notes here');
    });

    test('returns null when the manifest is empty', () {
      expect(AppUpdate.parse('\n# only a comment\n'), isNull);
    });

    test('isNewerThan compares against the current version', () {
      const update = AppUpdate(version: '1.2.0');

      expect(update.isNewerThan('1.1.0'), isTrue);
      expect(update.isNewerThan('1.2.0'), isFalse);
      expect(update.isNewerThan('1.3.0'), isFalse);
    });
  });
}
