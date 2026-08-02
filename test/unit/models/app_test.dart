import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/models/app.dart';

void main() {
  group('App', () {
    test('fromJson creates App from valid JSON', () {
      final json = {
        'id': 'app-123',
        'name': 'my-app',
        'region': {'name': 'us'},
        'stack': {'name': 'heroku-22'},
        'created_at': '2025-01-15T10:00:00Z',
        'updated_at': '2025-11-10T12:00:00Z',
        'web_url': 'https://my-app.herokuapp.com',
        'git_url': 'https://git.heroku.com/my-app.git',
        'maintenance': false,
        'buildpack_provided_description': 'Node.js',
        'owner': {'email': 'user@example.com'},
      };

      final app = App.fromJson(json);

      expect(app.id, equals('app-123'));
      expect(app.name, equals('my-app'));
      expect(app.region, equals('us'));
      expect(app.stack, equals('heroku-22'));
      expect(app.createdAt, isNotNull);
      expect(app.updatedAt, isNotNull);
      expect(app.webUrl, equals('https://my-app.herokuapp.com'));
      expect(app.gitUrl, equals('https://git.heroku.com/my-app.git'));
      expect(app.maintenance, equals(false));
      expect(app.buildpackProvidedDescription, equals('Node.js'));
      expect(app.owner, isNotNull);
      expect(app.owner!['email'], equals('user@example.com'));
    });

    test('fromJson handles minimal JSON', () {
      final json = {'id': 'app-456', 'name': 'minimal-app'};

      final app = App.fromJson(json);

      expect(app.id, equals('app-456'));
      expect(app.name, equals('minimal-app'));
      expect(app.region, isNull);
      expect(app.stack, isNull);
      expect(app.createdAt, isNull);
      expect(app.updatedAt, isNull);
      expect(app.webUrl, isNull);
      expect(app.gitUrl, isNull);
      expect(app.maintenance, isNull);
    });

    test('fromJson parses dates correctly', () {
      final json = {
        'id': 'app-789',
        'name': 'date-test-app',
        'created_at': '2025-11-10T12:34:56.789012Z',
        'updated_at': '2025-11-10T14:00:00.000000Z',
      };

      final app = App.fromJson(json);

      expect(app.createdAt, isNotNull);
      expect(app.createdAt!.year, equals(2025));
      expect(app.createdAt!.month, equals(11));
      expect(app.createdAt!.day, equals(10));
      expect(app.updatedAt, isNotNull);
    });

    test('toJson serializes App correctly', () {
      final app = App(
        id: 'app-111',
        name: 'test-app',
        region: 'eu',
        stack: 'heroku-22',
        createdAt: DateTime.parse('2025-01-15T10:00:00Z'),
        updatedAt: DateTime.parse('2025-11-10T12:00:00Z'),
        webUrl: 'https://test-app.herokuapp.com',
        gitUrl: 'https://git.heroku.com/test-app.git',
        maintenance: true,
        buildpackProvidedDescription: 'Python',
        owner: {'email': 'owner@example.com'},
      );

      final json = app.toJson();

      expect(json['id'], equals('app-111'));
      expect(json['name'], equals('test-app'));
      expect(json['region'], equals({'name': 'eu'}));
      expect(json['stack'], equals({'name': 'heroku-22'}));
      expect(json['created_at'], isNotNull);
      expect(json['updated_at'], isNotNull);
      expect(json['web_url'], equals('https://test-app.herokuapp.com'));
      expect(json['git_url'], equals('https://git.heroku.com/test-app.git'));
      expect(json['maintenance'], equals(true));
      expect(json['buildpack_provided_description'], equals('Python'));
      expect(json['owner'], equals({'email': 'owner@example.com'}));
    });

    test('toJson handles null values', () {
      final app = App(id: 'app-222', name: 'minimal-app');

      final json = app.toJson();

      expect(json['id'], equals('app-222'));
      expect(json['name'], equals('minimal-app'));
      expect(json['region'], isNull);
      expect(json['stack'], isNull);
      expect(json['created_at'], isNull);
      expect(json['web_url'], isNull);
      expect(json['maintenance'], isNull);
    });

    test('copyWith creates new instance with updated values', () {
      final original = App(
        id: 'app-333',
        name: 'original-app',
        region: 'us',
        maintenance: false,
      );

      final updated = original.copyWith(name: 'updated-app', maintenance: true);

      expect(updated.id, equals('app-333')); // Unchanged
      expect(updated.name, equals('updated-app')); // Changed
      expect(updated.region, equals('us')); // Unchanged
      expect(updated.maintenance, equals(true)); // Changed
    });

    test('copyWith with no arguments returns identical copy', () {
      final original = App(id: 'app-444', name: 'original-app', region: 'eu');

      final copy = original.copyWith();

      expect(copy.id, equals(original.id));
      expect(copy.name, equals(original.name));
      expect(copy.region, equals(original.region));
    });

    test('toString includes key fields', () {
      final app = App(
        id: 'app-555',
        name: 'string-test-app',
        region: 'us',
        maintenance: false,
      );

      final str = app.toString();

      expect(str, contains('app-555'));
      expect(str, contains('string-test-app'));
      expect(str, contains('us'));
      expect(str, contains('false'));
    });

    test('fromJson roundtrip preserves data', () {
      final json = {
        'id': 'app-666',
        'name': 'roundtrip-app',
        'region': {'name': 'us'},
        'stack': {'name': 'heroku-22'},
        'created_at': '2025-11-10T12:00:00Z',
        'web_url': 'https://roundtrip-app.herokuapp.com',
        'maintenance': true,
      };

      final app = App.fromJson(json);
      final jsonAgain = app.toJson();

      expect(jsonAgain['id'], equals(json['id']));
      expect(jsonAgain['name'], equals(json['name']));
      expect(jsonAgain['maintenance'], equals(json['maintenance']));
    });
  });
}
