import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/models/log_entry.dart';

void main() {
  group('LogEntry', () {
    test('parse valid log line with dyno', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Server started on port 5000';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.source, equals('app'));
      expect(logEntry.dyno, equals('web.1'));
      expect(logEntry.message, equals('Server started on port 5000'));
      expect(logEntry.level, equals(LogLevel.info));
      expect(logEntry.timestamp.year, equals(2025));
      expect(logEntry.timestamp.month, equals(11));
      expect(logEntry.timestamp.day, equals(10));
    });

    test('parse valid log line without dyno', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 heroku: State changed from starting to up';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.source, equals('heroku'));
      expect(logEntry.dyno, isNull);
      expect(logEntry.message, equals('State changed from starting to up'));
      expect(logEntry.level, equals(LogLevel.info));
    });

    test('parse log line with error message', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Error: Connection timeout';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.level, equals(LogLevel.error));
      expect(logEntry.message, equals('Error: Connection timeout'));
    });

    test('parse log line with warning message', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Warning: High memory usage';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.level, equals(LogLevel.warning));
      expect(logEntry.message, equals('Warning: High memory usage'));
    });

    test('infer error level from exception keyword', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Unhandled exception occurred';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.level, equals(LogLevel.error));
    });

    test('infer error level from failed keyword', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Request failed to complete';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.level, equals(LogLevel.error));
    });

    test('infer warning level from deprecated keyword', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 app[web.1]: Deprecated API usage detected';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.level, equals(LogLevel.warning));
    });

    test('parse malformed log line returns as plain text', () {
      const rawLine = 'This is not a properly formatted log line';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.source, equals('unknown'));
      expect(logEntry.message, equals(rawLine));
      expect(logEntry.level, equals(LogLevel.info));
      expect(logEntry.dyno, isNull);
    });

    test('parse router log', () {
      const rawLine =
          '2025-11-10T12:34:56.789012+00:00 router: at=info method=GET path="/api/users" host=myapp.herokuapp.com';

      final logEntry = LogEntry.parse(rawLine);

      expect(logEntry.source, equals('router'));
      expect(logEntry.dyno, isNull);
      expect(
        logEntry.message,
        contains('at=info method=GET path="/api/users"'),
      );
    });

    test('toString formats correctly with dyno', () {
      final logEntry = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'app',
        dyno: 'web.1',
        message: 'Test message',
        level: LogLevel.info,
      );

      expect(logEntry.toString(), contains('app[web.1]: Test message'));
    });

    test('toString formats correctly without dyno', () {
      final logEntry = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'heroku',
        message: 'Test message',
        level: LogLevel.info,
      );

      expect(logEntry.toString(), contains('heroku: Test message'));
      expect(logEntry.toString(), isNot(contains('[]')));
    });

    test('equality operator works correctly', () {
      final logEntry1 = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'app',
        dyno: 'web.1',
        message: 'Test',
        level: LogLevel.info,
      );

      final logEntry2 = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'app',
        dyno: 'web.1',
        message: 'Test',
        level: LogLevel.info,
      );

      expect(logEntry1, equals(logEntry2));
    });

    test('equality operator returns false for different entries', () {
      final logEntry1 = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'app',
        dyno: 'web.1',
        message: 'Test',
        level: LogLevel.info,
      );

      final logEntry2 = LogEntry(
        timestamp: DateTime.parse('2025-11-10T12:34:56.789012Z'),
        source: 'app',
        dyno: 'web.2',
        message: 'Test',
        level: LogLevel.info,
      );

      expect(logEntry1, isNot(equals(logEntry2)));
    });
  });
}
