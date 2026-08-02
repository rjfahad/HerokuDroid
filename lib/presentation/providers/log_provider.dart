import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:herokudroid/data/models/log_entry.dart';
import 'package:herokudroid/data/models/log_session.dart';
import 'package:herokudroid/data/repositories/log_repository.dart';

/// Log connection states
enum LogConnectionState { disconnected, connecting, connected, paused, error }

/// Provider for log streaming state management
class LogProvider extends ChangeNotifier {
  final LogRepository _repository;
  String _token;

  LogProvider({required LogRepository repository, required String token})
    : _repository = repository,
      _token = token;

  final List<LogEntry> _logs = [];
  LogConnectionState _state = LogConnectionState.disconnected;
  String? _error;
  LogSession? _currentSession;
  StreamSubscription<LogEntry>? _subscription;

  static const int _maxLogs = 1000; // Limit for memory management

  List<LogEntry> get logs => _logs;
  LogConnectionState get state => _state;
  String? get error => _error;
  bool get isConnected => _state == LogConnectionState.connected;
  bool get isPaused => _state == LogConnectionState.paused;

  /// Update authentication token
  void updateToken(String token) {
    if (_token != token) {
      _token = token;
      // If currently connected, reconnect with new token
      if (_state == LogConnectionState.connected ||
          _state == LogConnectionState.paused) {
        // Disconnect and let user reconnect manually to avoid unexpected behavior
        disconnect();
      }
    }
  }

  /// Connect to log stream
  Future<void> connect(
    String appId, {
    String? dyno,
    String? source,
    int lines = 100,
  }) async {
    if (_state == LogConnectionState.connected ||
        _state == LogConnectionState.connecting) {
      return; // Already connected or connecting
    }

    _state = LogConnectionState.connecting;
    _error = null;
    _logs.clear();
    notifyListeners();

    try {
      // Create log session
      _currentSession = await _repository.createLogSession(
        appId,
        dyno: dyno,
        source: source,
        tail: true,
        lines: lines,
      );

      // Start streaming
      final stream = await _repository.streamLogs(_currentSession!, _token);

      // Listen to stream
      _subscription = stream.listen(
        (entry) {
          _logs.add(entry);

          // Limit logs to prevent memory issues
          if (_logs.length > _maxLogs) {
            _logs.removeAt(0);
          }

          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _state = LogConnectionState.error;
          notifyListeners();
        },
        onDone: () {
          _state = LogConnectionState.disconnected;
          notifyListeners();
        },
        cancelOnError: false,
      );

      _state = LogConnectionState.connected;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _state = LogConnectionState.error;
      notifyListeners();
    }
  }

  /// Pause log streaming
  void pause() {
    if (_state != LogConnectionState.connected) return;

    _repository.pauseStream();
    _state = LogConnectionState.paused;
    notifyListeners();
  }

  /// Resume log streaming
  void resume() {
    if (_state != LogConnectionState.paused) return;

    _repository.resumeStream();
    _state = LogConnectionState.connected;
    notifyListeners();
  }

  /// Disconnect from log stream
  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _repository.disconnect();

    _subscription = null;
    _currentSession = null;
    _state = LogConnectionState.disconnected;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear logs
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
