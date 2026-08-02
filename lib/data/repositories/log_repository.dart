import 'package:herokudroid/core/constants/api_constants.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/models/log_entry.dart';
import 'package:herokudroid/data/models/log_session.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';
import 'package:herokudroid/data/services/log_stream_service.dart';

/// Repository for log operations
class LogRepository {
  final HerokuApiService _apiService;
  final LogStreamService _streamService;

  LogRepository({
    required HerokuApiService apiService,
    required LogStreamService streamService,
  }) : _apiService = apiService,
       _streamService = streamService;

  /// Create a log session
  Future<LogSession> createLogSession(
    String appId, {
    String? dyno,
    String? source,
    bool tail = true,
    int lines = 100,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.logSessions(appId),
        data: {
          if (dyno != null) 'dyno': dyno,
          if (source != null) 'source': source,
          'tail': tail,
          'lines': lines,
        },
      );
      return LogSession.fromJson(response.data as Map<String, dynamic>);
    } on HerokuException {
      rethrow;
    } catch (e) {
      throw HerokuException(
        message: 'Failed to create log session',
        originalError: e,
      );
    }
  }

  /// Start streaming logs
  Future<Stream<LogEntry>> streamLogs(LogSession session, String token) async {
    return await _streamService.connect(session.logplexUrl, token);
  }

  /// Pause log streaming
  void pauseStream() {
    _streamService.pause();
  }

  /// Resume log streaming
  void resumeStream() {
    _streamService.resume();
  }

  /// Disconnect from log stream
  Future<void> disconnect() async {
    await _streamService.disconnect();
  }

  bool get isConnected => _streamService.isConnected;
  bool get isPaused => _streamService.isPaused;
}
