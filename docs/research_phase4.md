# Phase 0.4: Log Streaming Research ⭐

**Date**: November 10, 2025  
**Phase**: Documentation Research - Log Streaming  
**Duration**: 2 days (critical feature)  
**Status**: ✅ COMPLETE

---

## Research Objective

Deep dive into Heroku log streaming, WebSocket/SSE architecture, and real-time Flutter UI updates for implementing the **PRIMARY FEATURE** of HerokuDroid: real-time log monitoring.

---

## 1. Heroku Log Sessions API

### API Endpoint

Based on existing `ApiConstants`:
```dart
/// Create log session
static String logSessions(String appId) => '/apps/$appId/log-sessions';
```

### Log Session Creation

**POST** `/apps/{app_id}/log-sessions`

**Request Body** (Optional filters):
```json
{
  "dyno": "web.1",        // Filter by specific dyno (optional)
  "source": "app",        // Filter by source: app, heroku, router (optional)
  "tail": true,           // Stream existing logs + new logs (default: false)
  "lines": 100            // Number of historical lines (default: 100, max: 1500)
}
```

**Response**:
```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "created_at": "2025-11-10T12:00:00Z",
  "updated_at": "2025-11-10T12:00:00Z",
  "logplex_url": "https://logplex.heroku.com/sessions/01234567?srv=123456"
}
```

### Critical Fields

- **`logplex_url`**: The URL to connect for streaming logs
  - This is an **HTTP streaming endpoint** (Server-Sent Events style)
  - NOT a WebSocket URL
  - Requires `Authorization: Bearer <token>` header

### Log Session Behavior

1. **Session Creation**: POST to `/apps/{id}/log-sessions` creates a session
2. **Connection**: Connect to `logplex_url` with proper authentication
3. **Streaming**: Logs stream as they occur (if `tail: true`)
4. **History**: Gets recent logs (specified by `lines` parameter)
5. **Timeout**: Sessions expire after inactivity (~1 hour typically)

---

## 2. Heroku Log Format

### Log Line Structure

Each log line follows this format:
```
2025-11-10T12:34:56.789012+00:00 app[web.1]: GET / 200 OK
^timestamp                        ^source ^dyno  ^message
```

**Components**:
- **Timestamp**: ISO 8601 format with microseconds
- **Source**: `app`, `heroku`, `router`, `postgres`, etc.
- **Dyno**: Process type and number (e.g., `web.1`, `worker.2`)
- **Message**: Actual log content

### Example Log Lines

```
2025-11-10T12:34:56.123456+00:00 app[web.1]: Started GET "/" for 203.0.113.1
2025-11-10T12:34:56.234567+00:00 app[web.1]: Processing by HomeController#index as HTML
2025-11-10T12:34:56.345678+00:00 heroku[router]: at=info method=GET path="/" host=myapp.herokuapp.com request_id=abc-123 fwd="203.0.113.1" dyno=web.1 connect=1ms service=12ms status=200 bytes=2048
2025-11-10T12:34:57.456789+00:00 heroku[web.1]: State changed from starting to up
```

### Log Levels (Inferred from Content)

Heroku logs don't have explicit levels, but we can infer:
- **INFO**: Normal operations, requests
- **WARN**: `warning`, `deprecated` in message
- **ERROR**: `error`, `exception`, `failed`, status 4xx/5xx

---

## 3. HTTP Streaming vs WebSocket

### Heroku's Choice: HTTP Streaming (SSE-like)

Heroku's `logplex_url` uses **HTTP streaming** (similar to Server-Sent Events):

**Characteristics**:
- Long-lived HTTP GET request
- Server pushes data as it becomes available
- Connection kept alive with chunked transfer encoding
- Simpler than WebSocket (no handshake upgrade)

**In Dart/Flutter**:
```dart
// Using Dio for streaming
final response = await _dio.get(
  logplexUrl,
  options: Options(
    headers: {'Authorization': 'Bearer $token'},
    responseType: ResponseType.stream, // Key: stream response
  ),
);

// Stream the response
response.data.stream.listen((data) {
  // Process log chunks
});
```

### Alternative: web_socket_channel

While Heroku uses HTTP streaming, the `web_socket_channel` package is still useful for understanding stream patterns:

**Installation** (already in IMPLEMENTATION_PLAN.md):
```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

**Not needed for Heroku logs** since we're using HTTP streaming, but good reference for future WebSocket features.

---

## 4. Data Model for Logs

### LogEntry Model

```dart
/// lib/data/models/log_entry.dart
class LogEntry {
  final DateTime timestamp;
  final String source;      // 'app', 'heroku', 'router', etc.
  final String? dyno;       // 'web.1', 'worker.2', null for some sources
  final String message;
  final LogLevel level;     // Inferred from message content
  
  LogEntry({
    required this.timestamp,
    required this.source,
    this.dyno,
    required this.message,
    required this.level,
  });
  
  /// Parse a raw log line
  factory LogEntry.parse(String rawLine) {
    // Regex to parse: timestamp source[dyno]: message
    final regex = RegExp(
      r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})\s+(\w+)(?:\[([^\]]+)\])?:\s+(.+)$'
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
  
  static LogLevel _inferLevel(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('error') || lower.contains('exception') || lower.contains('failed')) {
      return LogLevel.error;
    }
    if (lower.contains('warn') || lower.contains('deprecated')) {
      return LogLevel.warning;
    }
    return LogLevel.info;
  }
}

enum LogLevel {
  info,
  warning,
  error,
}
```

### LogSession Model

```dart
/// lib/data/models/log_session.dart
class LogSession {
  final String id;
  final String logplexUrl;
  final DateTime createdAt;
  
  LogSession({
    required this.id,
    required this.logplexUrl,
    required this.createdAt,
  });
  
  factory LogSession.fromJson(Map<String, dynamic> json) {
    return LogSession(
      id: json['id'] as String,
      logplexUrl: json['logplex_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

---

## 5. Log Streaming Service Architecture

### LogStreamService

```dart
/// lib/data/services/log_stream_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:herokuandroid/data/models/log_entry.dart';

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
      _processStream(response.data.stream);
      
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
```

---

## 6. Log Repository

### LogRepository

```dart
/// lib/data/repositories/log_repository.dart
import 'package:herokuandroid/core/constants/api_constants.dart';
import 'package:herokuandroid/data/models/log_entry.dart';
import 'package:herokuandroid/data/models/log_session.dart';
import 'package:herokuandroid/data/services/heroku_api_service.dart';
import 'package:herokuandroid/data/services/log_stream_service.dart';

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
    } catch (e) {
      throw Exception('Failed to create log session: $e');
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
```

---

## 7. Flutter StreamBuilder Pattern

### Real-time Log Viewer with StreamBuilder

```dart
class LogViewer extends StatelessWidget {
  final Stream<LogEntry> logStream;
  
  const LogViewer({required this.logStream, super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LogEntry>(
      stream: logStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(message: snapshot.error.toString());
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(message: 'Connecting to logs...');
        }
        
        if (!snapshot.hasData) {
          return EmptyStateWidget(message: 'No logs yet');
        }
        
        // Display log entry
        final log = snapshot.data!;
        return LogEntryWidget(entry: log);
      },
    );
  }
}
```

### Accumulating Logs in ListView

For displaying all logs (not just latest), we need to accumulate them:

```dart
class LogsScreen extends StatefulWidget {
  final Stream<LogEntry> logStream;
  
  const LogsScreen({required this.logStream, super.key});
  
  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final List<LogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  StreamSubscription<LogEntry>? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = widget.logStream.listen((entry) {
      setState(() {
        _logs.add(entry);
        // Limit to last 1000 logs to prevent memory issues
        if (_logs.length > 1000) {
          _logs.removeAt(0);
        }
      });
      
      // Auto-scroll to bottom if enabled
      if (_autoScroll && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Auto-scroll toggle
        SwitchListTile(
          title: const Text('Auto-scroll'),
          value: _autoScroll,
          onChanged: (value) {
            setState(() {
              _autoScroll = value;
            });
          },
        ),
        
        // Log list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return LogEntryWidget(entry: _logs[index]);
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 8. Auto-Scrolling Behavior

### Smart Auto-Scroll Logic

```dart
class _LogsScreenState extends State<LogsScreen> {
  bool _autoScroll = true;
  bool _userScrolled = false;
  
  @override
  void initState() {
    super.initState();
    
    // Detect user scroll
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.position.pixels >= 
                         _scrollController.position.maxScrollExtent - 50;
      
      if (!isAtBottom && !_userScrolled) {
        setState(() {
          _userScrolled = true;
          _autoScroll = false;
        });
      } else if (isAtBottom && _userScrolled) {
        setState(() {
          _userScrolled = false;
          _autoScroll = true;
        });
      }
    });
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
```

---

## 9. Log Filtering

### Filter Options

```dart
class LogFilter {
  final String? source;      // 'app', 'heroku', 'router'
  final String? dyno;        // 'web.1', 'worker.2'
  final LogLevel? level;     // info, warning, error
  final String? searchText;  // Text search in message
  
  LogFilter({
    this.source,
    this.dyno,
    this.level,
    this.searchText,
  });
  
  bool matches(LogEntry entry) {
    if (source != null && entry.source != source) return false;
    if (dyno != null && entry.dyno != dyno) return false;
    if (level != null && entry.level != level) return false;
    if (searchText != null && 
        !entry.message.toLowerCase().contains(searchText!.toLowerCase())) {
      return false;
    }
    return true;
  }
}

// Usage in widget:
List<LogEntry> get _filteredLogs {
  if (_currentFilter == null) return _logs;
  return _logs.where((log) => _currentFilter!.matches(log)).toList();
}
```

---

## 10. UI Design Patterns

### Log Entry Widget with Color Coding

```dart
class LogEntryWidget extends StatelessWidget {
  final LogEntry entry;
  
  const LogEntryWidget({required this.entry, super.key});
  
  Color _getLevelColor() {
    switch (entry.level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
    }
  }
  
  IconData _getLevelIcon() {
    switch (entry.level) {
      case LogLevel.error:
        return Icons.error;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.info:
        return Icons.info;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _getLevelColor(),
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level icon
          Icon(
            _getLevelIcon(),
            size: 16,
            color: _getLevelColor(),
          ),
          const SizedBox(width: 8),
          
          // Log content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp and source
                Text(
                  '${_formatTime(entry.timestamp)} ${entry.source}${entry.dyno != null ? '[${entry.dyno}]' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                
                // Message
                SelectableText(
                  entry.message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
```

---

## 11. Connection Management

### Connection States

```dart
enum LogConnectionState {
  disconnected,
  connecting,
  connected,
  paused,
  error,
}
```

### Connection Indicator Widget

```dart
class ConnectionIndicator extends StatelessWidget {
  final LogConnectionState state;
  
  const ConnectionIndicator({required this.state, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state == LogConnectionState.connecting)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(_getColor()),
              ),
            )
          else
            Icon(_getIcon(), size: 16, color: _getColor()),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getColor() {
    switch (state) {
      case LogConnectionState.connected:
        return Colors.green;
      case LogConnectionState.paused:
        return Colors.orange;
      case LogConnectionState.error:
        return Colors.red;
      case LogConnectionState.connecting:
        return Colors.blue;
      case LogConnectionState.disconnected:
        return Colors.grey;
    }
  }
  
  IconData _getIcon() {
    switch (state) {
      case LogConnectionState.connected:
        return Icons.cloud_done;
      case LogConnectionState.paused:
        return Icons.pause_circle;
      case LogConnectionState.error:
        return Icons.error;
      case LogConnectionState.connecting:
        return Icons.cloud_sync;
      case LogConnectionState.disconnected:
        return Icons.cloud_off;
    }
  }
  
  String _getLabel() {
    switch (state) {
      case LogConnectionState.connected:
        return 'LIVE';
      case LogConnectionState.paused:
        return 'PAUSED';
      case LogConnectionState.error:
        return 'ERROR';
      case LogConnectionState.connecting:
        return 'CONNECTING';
      case LogConnectionState.disconnected:
        return 'OFFLINE';
    }
  }
}
```

---

## 12. Performance Optimizations

### Considerations

1. **Memory Management**: Limit logs to last 1000 entries
2. **ListView.builder**: Use builder for efficient rendering
3. **Lazy Loading**: Don't render off-screen log entries
4. **Text Selection**: Use `SelectableText` only where needed
5. **Debouncing**: Debounce search input to avoid excessive filtering

### Log Rotation

```dart
void _addLog(LogEntry entry) {
  setState(() {
    _logs.add(entry);
    
    // Keep only last 1000 logs
    const maxLogs = 1000;
    if (_logs.length > maxLogs) {
      _logs.removeRange(0, _logs.length - maxLogs);
    }
  });
}
```

---

## 13. Error Handling & Reconnection

### Auto-Reconnect Logic

```dart
Future<void> _connectWithRetry() async {
  int retryCount = 0;
  const maxRetries = 3;
  const retryDelay = Duration(seconds: 2);
  
  while (retryCount < maxRetries) {
    try {
      await _connect();
      return; // Success
    } catch (e) {
      retryCount++;
      if (retryCount < maxRetries) {
        await Future.delayed(retryDelay * retryCount);
      } else {
        rethrow; // Max retries reached
      }
    }
  }
}
```

---

## 14. Additional Features (Optional)

### Copy/Share Logs

```dart
void _copyLogs() {
  final text = _logs.map((e) => '${e.timestamp} ${e.source}[${e.dyno}]: ${e.message}').join('\n');
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied logs to clipboard')),
  );
}
```

### Export to File

```dart
Future<void> _exportLogs() async {
  final text = _logs.map((e) => '${e.timestamp} ${e.source}[${e.dyno}]: ${e.message}').join('\n');
  // Use share_plus or file_picker to save
  await Share.share(text, subject: 'Heroku Logs - ${widget.appName}');
}
```

---

## 15. Implementation Checklist for Phase 4

### Data Layer
- [ ] Create `LogEntry` model with parser
- [ ] Create `LogSession` model
- [ ] Create `LogStreamService` for HTTP streaming
- [ ] Create `LogRepository` for session management

### Presentation Layer
- [ ] Create `LogProvider` for state management
- [ ] Create `LogsScreen` with StreamBuilder
- [ ] Create `LogEntryWidget` with color coding
- [ ] Implement auto-scroll with manual override
- [ ] Add log filtering UI
- [ ] Add connection status indicator
- [ ] Add pause/resume controls
- [ ] Add copy/share functionality

### Integration
- [ ] Register LogProvider in main.dart
- [ ] Add navigation from app details
- [ ] Handle connection lifecycle (connect/disconnect)
- [ ] Implement error handling and retry logic

---

## 16. Key Takeaways

1. **HTTP Streaming, Not WebSocket**: Heroku uses HTTP streaming via logplex_url
2. **Log Parsing Required**: Must parse timestamp, source, dyno, message from each line
3. **Memory Management Critical**: Limit stored logs to prevent memory issues
4. **Auto-Scroll Intelligence**: Detect user scroll and disable auto-scroll
5. **Stream Management**: Use StreamController and handle lifecycle properly
6. **Filter Client-Side**: All filtering happens in Flutter, not server-side
7. **Connection Status**: Always show connection state to user
8. **Error Recovery**: Implement retry logic for connection failures

---

## Next Steps

Proceed to **Phase 4: Log Monitoring Implementation** with this research as foundation.

**Status**: ✅ Research complete - ready for implementation
