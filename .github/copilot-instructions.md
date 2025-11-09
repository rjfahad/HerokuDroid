# HerokuDroid - AI Coding Agent Instructions

## Project Overview

HerokuDroid is a Flutter Android app for managing Heroku applications with a **primary focus on real-time log monitoring**. The app uses Provider for state management, Dio for HTTP, and integrates with Heroku Platform API v3.

## Architecture Pattern

**3-Layer Architecture**: `presentation/` → `data/repositories/` → `data/services/`

- **Presentation Layer**: Screens, widgets, and ChangeNotifier providers (state management)
- **Repository Layer**: Business logic and API orchestration (repositories are stateless)
- **Service Layer**: HTTP client (`HerokuApiService`), secure storage, and future log streaming

**Dependency Injection**: All dependencies are instantiated in `main.dart` and injected via constructors. Providers are set up using `MultiProvider` at app root.

## State Management: Provider Pattern

- Use `ChangeNotifierProvider` for stateful providers (see `AuthProvider`, `AppsProvider`, `DynoProvider`)
- Providers own repositories (injected via constructor), **not services directly**
- All state mutations must call `notifyListeners()` after updates
- Standard state pattern: `_isLoading`, `_error`, and data fields with getters
- Access providers: `context.read<T>()` for one-time access, `Consumer<T>` for reactive UI

**Example from codebase**:
```dart
// In main.dart - setup
ChangeNotifierProvider(
  create: (_) => AuthProvider(repository: authRepository),
)

// In provider - state management
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  bool _isLoading = false;
  String? _error;
  
  Future<void> login(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.login(token);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## HTTP & API Integration

**Heroku API Service** (`lib/data/services/heroku_api_service.dart`):
- Singleton Dio instance with base URL: `https://api.heroku.com`
- **Auth Interceptor**: Automatically injects `Authorization: Bearer <token>` from `SecureStorageService`
- **Error Interceptor**: Converts all `DioException` to `HerokuException` (see `lib/core/errors/heroku_exception.dart`)
- Required headers: `Accept: application/vnd.heroku+json; version=3`, `Content-Type: application/json`
- All API endpoints defined as static methods in `ApiConstants` (e.g., `ApiConstants.app(appId)`)

**Authentication Flow**:
1. Token stored in `flutter_secure_storage` (encrypted Android keystore)
2. Token validated via `testConnection()` API call on login
3. `AuthProvider.checkAuthStatus()` runs on app start to restore session

## Data Models

All models in `lib/data/models/` follow this pattern:
- Immutable classes with named constructors
- `fromJson()` factory for deserialization (handles nested objects like `region: {'name': 'us'}`)
- `toJson()` for serialization
- `copyWith()` for immutable updates
- Nullable fields for optional API responses

**Example**: `App` model handles Heroku's nested JSON structure:
```dart
factory App.fromJson(Map<String, dynamic> json) {
  return App(
    id: json['id'] as String,
    region: json['region']?['name'] as String?, // Extract nested field
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String) 
        : null,
  );
}
```

## File Organization

- **Screens**: `lib/presentation/screens/{feature}/{screen_name}_screen.dart`
  - Current: `auth/`, `dashboard/`, `app_details/`
  - Place feature-specific widgets in nested `widgets/` folder
- **Shared Widgets**: `lib/presentation/widgets/common/` (e.g., `app_card.dart`, `loading_widget.dart`)
- **Constants**: All magic strings/values in `lib/core/constants/` (API endpoints, theme, app config)
- **Routes**: Centralized in `lib/core/routes/app_routes.dart` (not yet fully implemented)

## Development Workflow

**Phase-Based Implementation**: Project follows a phased approach documented in `IMPLEMENTATION_PLAN.md`:
- **Phase 0.x**: Documentation research using Context7 MCP (findings in `docs/research_phaseX.md`)
- **Phase 1**: Foundation (✅ COMPLETE - auth + dashboard)
- **Phase 2**: Dyno management (in progress)
- **Phase 4**: Log streaming ⭐ (PRIMARY FEATURE - upcoming)

**Research-First Approach**: Before implementing features, research API docs and Flutter patterns using MCP tools. Document findings in `docs/` before coding.

## Testing Strategy

- Unit tests for repositories and services
- Widget tests for screens and components
- Use `mockito` for mocking API responses
- Test files mirror source structure in `test/` directory

## Flutter-Specific Conventions

- Use `const` constructors wherever possible for performance
- Async methods return `Future<void>` or `Future<T>`, never return raw data without type
- Error handling: Use try-catch in providers/repositories, display errors via `SnackBar` in UI
- Loading states: Always show `CircularProgressIndicator` during async operations
- Navigation: Use `Navigator.pushReplacement()` for login→dashboard flow (prevent back navigation)

## Critical Implementation Notes

**Heroku API Quirks**:
- Dyno operations (restart/scale) require specific endpoints: `/apps/{id}/formation/{type}` for scaling
- Log streaming requires creating a log session first, then connecting to returned `logplex_url` (WebSocket/SSE)
- Config vars are returned as flat `Map<String, String>`, not array of objects

**Security**:
- Never log API tokens (interceptor debug logs exclude Authorization header)
- Use `flutter_secure_storage` for token persistence (already integrated)
- Token validation happens on app start and before each critical operation

## Common Commands

```powershell
# Install dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test
```

## Next Steps (Current Development Phase)

Based on `IMPLEMENTATION_PLAN.md`, the current focus is:
1. Complete dyno management screens (Phase 2)
2. Research log streaming architecture (Phase 0.4)
3. Implement real-time log viewer (Phase 4 - PRIMARY FEATURE)

When implementing new features:
1. Check if research phase documentation exists in `docs/`
2. Add new models to `lib/data/models/`
3. Add repository methods to relevant repository
4. Create provider for state management
5. Build UI in appropriate `screens/` subfolder
6. Register provider in `main.dart`'s `MultiProvider`
