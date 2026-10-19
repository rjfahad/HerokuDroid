import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/core/utils/version_utils.dart';

void main() {
  group('compareVersions', () {
    test('orders numeric components', () {
      expect(compareVersions('1.2.0', '1.1.9'), greaterThan(0));
      expect(compareVersions('1.1.9', '1.2.0'), lessThan(0));
      expect(compareVersions('2.0.0', '2.0.0'), 0);
    });

    test('ignores a leading v and build/pre-release suffixes', () {
      expect(compareVersions('v1.2.3', '1.2.3'), 0);
      expect(compareVersions('1.2.3+4', '1.2.3'), 0);
      expect(compareVersions('1.2.3-beta.1', '1.2.3'), 0);
    });

    test('treats missing trailing components as zero', () {
      expect(compareVersions('1.2', '1.2.0'), 0);
      expect(compareVersions('1.2.1', '1.2'), greaterThan(0));
    });

    test('isNewerVersion only reports strictly newer', () {
      expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('0.9.0', '1.0.0'), isFalse);
    });
  });
}
