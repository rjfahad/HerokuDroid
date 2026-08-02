import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:herokudroid/data/models/log_entry.dart';

/// Service for streaming logs from Heroku logplex URL
class LogStreamService {
  final Dio _dio;
  StreamController<LogEntry>? _logController;
  CancelToken? _cancelToken;
  bool _isPaused = false;

  LogStreamService(this._dio);

  /// Start streaming logs from logplex URL
  Future<Stream<LogEntry>> connect(String logplexUrl, String token) async {
    // Close any existing stream
    await disconnect();

    _logController = StreamController<LogEntry>.broadcast();
    _cancelToken = CancelToken();

    try {
      final response = await _dio.get(
        logplexUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.stream,
        ),
        cancelToken: _cancelToken,
      );

      // Process the stream
      _processStream(response.data.stream as Stream<List<int>>);

      return _logController!.stream;
    } catch (e) {
      _logController?.addError(e);
      return _logController!.stream;
    }
  }

  void _processStream(Stream<List<int>> stream) {
    String buffer = '';

    stream.listen(
      (data) {
        if (_isPaused) return;

        // Convert bytes to string
        buffer += utf8.decode(data);

        // Split by newlines
        final lines = buffer.split('\n');
        buffer = lines.last; // Keep incomplete line in buffer

        // Parse complete lines
        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.isNotEmpty) {
            try {
              final entry = LogEntry.parse(line);
              _logController?.add(entry);
            } catch (e) {
              // Skip malformed lines
              print('[LogStreamService] Failed to parse line: $line');
            }
          }
        }
      },
      onError: (error) {
        _logController?.addError(error);
      },
      onDone: () {
        _logController?.close();
      },
      cancelOnError: false,
    );
  }

  /// Pause log streaming (don't add to stream)
  void pause() {
    _isPaused = true;
  }

  /// Resume log streaming
  void resume() {
    _isPaused = false;
  }

  /// Disconnect from log stream
  Future<void> disconnect() async {
    _cancelToken?.cancel();
    await _logController?.close();
    _logController = null;
    _cancelToken = null;
    _isPaused = false;
  }

  bool get isConnected => _logController != null && !_logController!.isClosed;
  bool get isPaused => _isPaused;
}
