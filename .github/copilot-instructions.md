# HerokuDroid - AI Coding Agent Instructions

## Project Overview

HerokuDroid is a Flutter Android app for managing Heroku applications with **real-time log monitoring as its primary feature**. Built with Provider for state management, Dio for HTTP, and Heroku Platform API v3.

**Current Status**: Phase 5 (Testing & Polish) - Log streaming ✅ complete, dyno management ✅ complete, config vars ✅ complete, add-ons ✅ complete.

## Architecture: 3-Layer Clean Pattern

```
presentation/ (UI + State) → data/repositories/ (Business Logic) → data/services/ (HTTP + Storage)
```

- **Presentation**: Screens, widgets, `ChangeNotifier` providers
- **Repositories**: Stateless orchestrators calling services
- **Services**: `HerokuApiService` (HTTP), `SecureStorageService`, `LogStreamService` (HTTP streaming)

**Critical DI Pattern**: All services and repositories instantiated in `main.dart`, then injected via constructor:

```dart
// main.dart - SINGLE SOURCE OF TRUTH for dependencies
final apiService = HerokuApiService(secureStorage);
final appRepository = AppRepository(apiService: apiService);
// ...then providers consume repositories
ChangeNotifierProvider(create: (_) => AppsProvider(repository: appRepository))
```

## State Management: Provider with Strict Patterns

**ALWAYS follow this pattern** when creating/modifying providers:

```dart
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  bool _isLoading = false;
  String? _error;
  MyData? _data;
  
  // Public getters (NO public setters)
  bool get isLoading => _isLoading;
  String? get error => _error;
  MyData? get data => _data;
  
  Future<void> someAction() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // REQUIRED after state change
    
    try {
      _data = await _repository.doSomething();
    } on HerokuException catch (e) {
      _error = e.message; // Use HerokuException.message for user-facing errors
    } finally {
      _isLoading = false;
      notifyListeners(); // REQUIRED in finally block
    }
  }
}
```

**Provider Access Patterns**:
- `context.read<T>()` - One-time access (event handlers, initState)
- `Consumer<T>` - Rebuild widget on state change
- `context.watch<T>()` - Inside build methods ONLY

**Special Case: `ChangeNotifierProxyProvider`** - Used in `LogProvider` to inject token from `AuthProvider`:

```dart
// Automatically rebuilds LogProvider when AuthProvider.token changes
ChangeNotifierProxyProvider<AuthProvider, LogProvider>(
  create: (_) => LogProvider(repository: logRepo, token: ''),
  update: (_, authProvider, logProvider) => logProvider!..updateToken(authProvider.token ?? ''),
)
```

## HTTP & API Integration Patterns

**`HerokuApiService`** - Centralized HTTP client with interceptors:

```dart
// Auth interceptor: Auto-injects token from secure storage
// Error interceptor: Converts DioException → HerokuException
// Logging interceptor: Debug output (NEVER logs Authorization header)

// All endpoints in ApiConstants as static methods:
ApiConstants.app(appId)           // '/apps/{appId}'
ApiConstants.formation(appId)     // '/apps/{appId}/formation'
ApiConstants.logSessions(appId)   // '/apps/{appId}/log-sessions'
```

**Required Headers** (handled automatically):
```dart
'Accept': 'application/vnd.heroku+json; version=3'
'Content-Type': 'application/json'
'Authorization': 'Bearer <token>' // From interceptor
```

**Error Handling Flow**:
1. Dio throws `DioException`
2. Error interceptor wraps as `HerokuException` with user-friendly message
3. Repositories catch and rethrow `HerokuException`
4. Providers catch and set `_error = e.message`
5. UI displays `SnackBar` or error widget

**Heroku API Quirks to Remember**:
- Nested JSON fields: `json['region']['name']` → extract with `json['region']?['name']`
- Config vars are flat `Map<String, String>`, not array
- Dyno scaling uses `/apps/{id}/formation/{type}` with PATCH `{quantity: n, size: "standard-1X"}`
- **Log streaming**: Create session → POST `/apps/{id}/log-sessions` → returns `logplex_url` → HTTP stream (NOT WebSocket)

## Real-Time Log Streaming Architecture ⭐

**Critical Implementation Details**:

1. **Create Log Session** (`LogRepository.createLogSession`):
   ```dart
   POST /apps/{appId}/log-sessions
   Body: {dyno?: string, source?: string, tail: true, lines: 100}
   Response: {id, logplex_url, created_at}
   ```

2. **HTTP Streaming** (`LogStreamService.connect`):
   ```dart
   // Uses Dio with ResponseType.stream (NOT WebSocket)
   final response = await _dio.get(logplexUrl, 
     options: Options(responseType: ResponseType.stream));
   // Process stream: bytes → UTF-8 → line-buffered → LogEntry.parse()
   ```

3. **Log Parsing** (`LogEntry.parse`):
   ```dart
   // Format: "2025-11-10T12:34:56.789Z app[web.1]: Starting server"
   // Regex extracts: timestamp, source, dyno, message
   // Log level inferred from keywords (error, warn, exception)
   ```

4. **Memory Management**:
   ```dart
   // LogProvider maintains max 1000 logs in memory
   if (_logs.length > _maxLogs) _logs.removeAt(0);
   ```

5. **State Machine** (`LogConnectionState` enum):
   ```
   disconnected → connecting → connected ⇄ paused → disconnected
                            ↓ (on error)
                          error
   ```

## Data Models: Immutability & JSON Handling

**Standard Model Pattern** (see `lib/data/models/app.dart`):

```dart
class MyModel {
  final String id;
  final String? optionalField;
  
  MyModel({required this.id, this.optionalField});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as String,
      optionalField: json['optional_field'] as String?, // Nullable cast
    );
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'optional_field': optionalField};
  
  MyModel copyWith({String? id, String? optionalField}) => MyModel(
    id: id ?? this.id,
    optionalField: optionalField ?? this.optionalField,
  );
}
```

**Special Case: `LogEntry.parse(String)`** - Uses regex for Heroku log format (not JSON).

## UI Patterns & Conventions

**Loading States** - Use `Skeletonizer` package (Phase 5):
```dart
// Replace CircularProgressIndicator with skeleton screens
Skeletonizer(
  enabled: isLoading,
  child: ListView.builder(
    itemCount: isLoading ? 5 : data.length, // Show 5 skeletons
    itemBuilder: (ctx, idx) => AppCardSkeleton(), // Custom skeleton widget
  ),
)
```

**Pull-to-Refresh** - Wrap list views:
```dart
RefreshIndicator(
  onRefresh: () => context.read<MyProvider>().refresh(),
  child: ListView.builder(...),
)
```

**Navigation**:
- Login → Dashboard: `Navigator.pushReplacement()` (prevent back button)
- Dashboard → Details: `Navigator.push()` (allow back)

**Error Display**:
```dart
if (error != null)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error!), backgroundColor: Colors.red),
  );
```

## File Organization & Naming

```
lib/
├── core/
│   ├── constants/api_constants.dart      # All endpoints as static methods
│   ├── errors/heroku_exception.dart      # Custom exception with statusCode
│   └── utils/                            # Formatters, validators
├── data/
│   ├── models/                           # Immutable with fromJson/toJson
│   ├── repositories/                     # Business logic (stateless)
│   └── services/                         # HTTP, storage, streaming
├── presentation/
│   ├── providers/                        # ChangeNotifier state managers
│   ├── screens/{feature}/                # Feature folders (auth/, dashboard/, logs/)
│   │   └── {feature}_screen.dart
│   └── widgets/
│       ├── common/                       # Reusable (app_card.dart, skeleton_widgets.dart)
│       └── dialogs/
└── main.dart                             # DI container + MultiProvider setup
```

**Naming Conventions**:
- Screens: `{feature}_screen.dart` (e.g., `dashboard_screen.dart`)
- Providers: `{feature}_provider.dart` (e.g., `apps_provider.dart`)
- Repositories: `{feature}_repository.dart` (e.g., `app_repository.dart`)
- Models: `{entity}.dart` (e.g., `app.dart`, `log_entry.dart`)

## Development Workflow

**Before implementing features**:
1. Check `IMPLEMENTATION_PLAN.md` for phase status
2. Review `docs/research_phase{N}.md` for API/pattern research
3. Check existing similar feature implementations

**When adding a new feature**:
1. Create model in `lib/data/models/`
2. Add API endpoint to `ApiConstants`
3. Create/update repository in `lib/data/repositories/`
4. Create provider in `lib/presentation/providers/`
5. Register provider in `main.dart` `MultiProvider`
6. Build screen in `lib/presentation/screens/{feature}/`

**Common Commands** (PowerShell):
```powershell
flutter pub get                # Install dependencies
flutter run                    # Debug mode (hot reload enabled)
flutter analyze                # Lint checks
flutter format .               # Auto-format all files
flutter test                   # Run unit/widget tests
flutter build apk --release    # Production build
```

## Testing Strategy

- Unit tests: Repositories and services (mock API responses with `mockito`)
- Widget tests: Screens and components
- Test files mirror `lib/` structure in `test/`
- Not yet fully implemented (Phase 5 in progress)

## Security & Sensitive Data

**CRITICAL**:
- API tokens stored in `flutter_secure_storage` (Android keystore encryption)
- NEVER log tokens in debug output (interceptor specifically excludes Authorization header)
- Token validation on app start via `AuthProvider.checkAuthStatus()`
- Invalid tokens trigger automatic logout

## Research-First Approach (Context7 MCP)

This project uses **Context7 MCP** for documentation research before implementation. See `docs/` for research notes:

- `research_phase1.md` - Foundation (Provider, Dio, secure storage)
- `research_phase2.md` - Dyno management
- `research_phase3.md` - Config vars & add-ons
- `research_phase4.md` - Log streaming (HTTP streaming vs WebSocket decision)
- `research_phase5.md` - Testing patterns, shimmer loading

**When researching**:
1. Use `mcp_upstash_conte_resolve-library-id` to find library IDs
2. Use `mcp_upstash_conte_get-library-docs` to fetch docs
3. Document findings in `docs/research_phase{N}.md` BEFORE coding

## Known Issues & Edge Cases

1. **Log Streaming Disconnect**: No auto-reconnect on network loss (user must manually reconnect)
2. **Memory Management**: Logs capped at 1000 entries (older entries dropped)
3. **Token Expiry**: No token refresh mechanism (user must re-login)
4. **Heroku API Rate Limits**: Not handled (429 errors shown as generic server error)

## Next Steps (Current Phase: 5 - Testing & Polish)

See `docs/PHASE5_CHECKLIST.md` for detailed tasks. Focus areas:
- Unit tests for repositories
- Widget tests for screens
- Dark mode theme refinement
- Performance optimization
