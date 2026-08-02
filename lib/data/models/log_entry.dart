/// Log level enum
enum LogLevel { info, warning, error }

/// Heroku log entry model
class LogEntry {
  final DateTime timestamp;
  final String source; // 'app', 'heroku', 'router', etc.
  final String? dyno; // 'web.1', 'worker.2', null for some sources
  final String message;
  final LogLevel level; // Inferred from message content

  LogEntry({
    required this.timestamp,
    required this.source,
    this.dyno,
    required this.message,
    required this.level,
  });

  /// Parse a raw Heroku log line
  /// Format: 2025-11-10T12:34:56.789012+00:00 app[web.1]: message
  factory LogEntry.parse(String rawLine) {
    // Regex to parse: timestamp source[dyno]: message
    final regex = RegExp(
      r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})\s+(\w+)(?:\[([^\]]+)\])?:\s+(.+)$',
    );

    final match = regex.firstMatch(rawLine);
    if (match == null) {
      // Malformed line, return as plain text
      return LogEntry(
        timestamp: DateTime.now(),
        source: 'unknown',
        message: rawLine,
        level: LogLevel.info,
      );
    }

    return LogEntry(
      timestamp: DateTime.parse(match.group(1)!),
      source: match.group(2)!,
      dyno: match.group(3),
      message: match.group(4)!,
      level: _inferLevel(match.group(4)!),
    );
  }

  /// Infer log level from message content
  static LogLevel _inferLevel(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('error') ||
        lower.contains('exception') ||
        lower.contains('failed') ||
        lower.contains('fatal')) {
      return LogLevel.error;
    }
    if (lower.contains('warn') ||
        lower.contains('deprecated') ||
        lower.contains('notice')) {
      return LogLevel.warning;
    }
    return LogLevel.info;
  }

  @override
  String toString() {
    final dynoStr = dyno != null ? '[$dyno]' : '';
    return '${timestamp.toIso8601String()} $source$dynoStr: $message';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogEntry &&
        other.timestamp == timestamp &&
        other.source == source &&
        other.dyno == dyno &&
        other.message == message &&
        other.level == level;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        source.hashCode ^
        dyno.hashCode ^
        message.hashCode ^
        level.hashCode;
  }
}
