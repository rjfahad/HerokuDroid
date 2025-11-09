# Phase 0.1: Documentation Research - Foundation

**Date**: November 10, 2025  
**Phase**: Foundation Research  
**Duration**: 1 day  

---

## Objectives

Research Flutter best practices, secure storage, and HTTP client setup for building the Heroku Android client.

### Topics to Research

1. Flutter project structure and architecture patterns
2. State management with provider
3. HTTP client and API integration
4. flutter_secure_storage for token management
5. dio/http package for interceptors and authentication

---

## Research Findings

### 1. Flutter Project Structure and Architecture Patterns

**Library Researched**: Flutter SDK (/websites/docs_flutter_dev)

**Key Findings**:

- **MVVM Pattern**: Flutter recommends MVVM (Model-View-ViewModel) architecture using `ChangeNotifier`
- **Command Pattern**: Use Command classes for UI actions, separating business logic from widgets
- **Directory Structure**: Recommended structure includes:
  ```
  lib/
    ├── core/           # Constants, utils, routes
    ├── data/           # Models, repositories, services
    └── presentation/   # Screens, widgets, providers
  ```
- **Separation of Concerns**: ViewModels extend `ChangeNotifier` to manage state and notify UI of changes
- **Isolate Pattern**: For background processing (useful for log parsing)

**Code Pattern Example**:
```dart
class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    load = Command0(_load)..execute();
  }
  
  late final Command0 load;
  
  Future<Result<void>> _load() async {
    // Load data
    notifyListeners();
  }
}
```

---

### 2. State Management with Provider

**Library Researched**: provider package (/websites/pub_dev_packages_provider)

**Key Findings**:

- **ChangeNotifier Pattern**: Simplest way to manage state in Flutter
- **Provider Types**:
  - `ChangeNotifierProvider`: For mutable state that notifies listeners
  - `Provider.value`: For existing objects
  - `MultiProvider`: For providing multiple objects
- **Consumption Methods**:
  - `Provider.of<T>(context, listen: false)` - For methods/one-time reads
  - `context.watch<T>()` - For reactive UI updates
  - `context.read<T>()` - For non-reactive access
  - `Consumer<T>` widget - For scoped rebuilds

**Usage Example**:
```dart
// Provide
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppsProvider()),
    ChangeNotifierProvider(create: (_) => LogProvider()),
  ],
  child: MyApp(),
)

// Consume
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appsProvider = context.watch<AppsProvider>();
    return Text('${appsProvider.apps.length} apps');
  }
}
```

---

### 3. HTTP Client and API Integration

**Library Researched**: dio package (/cfug/dio)

**Key Findings**:

- **Dio vs http**: Dio is recommended for production apps with advanced features
- **Interceptors**: Powerful for adding authentication, logging, error handling
  - `InterceptorsWrapper`: For request/response/error modification
  - `QueuedInterceptor`: For sequential processing (token refresh)
- **Error Handling**: `DioException` with detailed error types:
  - `connectionTimeout`, `sendTimeout`, `receiveTimeout`
  - `badResponse` (4xx, 5xx)
  - `connectionError`, `cancel`, `badCertificate`
- **Features**: Global config, retry logic, request cancellation, FormData, file upload/download

**Interceptor Example**:
```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['Accept'] = 'application/vnd.heroku+json; version=3';
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Handle token refresh
      }
      handler.next(error);
    },
  ),
);
```

---

### 4. flutter_secure_storage

**Library Researched**: flutter_secure_storage (/websites/pub_dev_packages_flutter_secure_storage)

**Key Findings**:

- **Platform Security**:
  - iOS: Keychain
  - Android: KeyStore with AES encryption
  - Minimum SDK: Android 18 (API level 18)
- **Basic Operations**: read, write, delete, deleteAll, containsKey
- **Platform Options**:
  - Android: `encryptedSharedPreferences`, custom encryption
  - iOS: `accessibility` levels
- **Best Practice**: Initialize once, reuse instance

**Usage Example**:
```dart
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

// Store token
await storage.write(key: 'heroku_token', value: token);

// Read token
final token = await storage.read(key: 'heroku_token');

// Delete token on logout
await storage.delete(key: 'heroku_token');
```

---

### 5. Dio Package (Detailed)

**Library Researched**: dio package (/cfug/dio, /websites/pub_dev_dio)

**Additional Findings**:

- **BaseOptions Configuration**:
  ```dart
  Dio(BaseOptions(
    baseUrl: 'https://api.heroku.com',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ))
  ```
- **Custom Validation**: Control which status codes are considered successful
- **Transformers**: Custom JSON encoding/decoding (useful for Flutter isolates)
- **Cookie Management**: Available via `dio_cookie_manager` plugin
- **Logging**: Built-in `LogInterceptor` for debugging

**Error Handling Pattern**:
```dart
try {
  final response = await dio.get('/apps');
} on DioException catch (e) {
  if (e.response != null) {
    // Server responded with error
    handleErrorResponse(e.response);
  } else {
    // Network or timeout error
    handleNetworkError(e.type);
  }
}
```

---

## Architectural Decisions

Based on the research findings, here are the architectural decisions for the HerokuDroid project:

### 1. Project Structure

**Decision**: Follow Flutter's recommended MVVM architecture with clear separation of concerns

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # Heroku API URLs, headers
│   │   ├── app_constants.dart       # App-wide constants
│   │   └── theme_constants.dart     # Colors, text styles
│   ├── errors/
│   │   └── heroku_exception.dart    # Custom exception classes
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── log_parser.dart
│   │   └── validators.dart
│   └── routes/
│       └── app_routes.dart          # Named routes
│
├── data/
│   ├── models/
│   │   ├── app.dart                 # Data models with JSON serialization
│   │   ├── dyno.dart
│   │   ├── formation.dart
│   │   ├── config_var.dart
│   │   ├── addon.dart
│   │   └── log_entry.dart
│   ├── repositories/
│   │   ├── auth_repository.dart     # Token management
│   │   ├── app_repository.dart      # App CRUD operations
│   │   ├── dyno_repository.dart     # Dyno management
│   │   └── log_repository.dart      # Log streaming
│   └── services/
│       ├── heroku_api_service.dart  # Dio HTTP client
│       ├── secure_storage_service.dart
│       └── log_stream_service.dart  # WebSocket handler
│
└── presentation/
    ├── providers/                   # ChangeNotifier classes
    │   ├── auth_provider.dart
    │   ├── apps_provider.dart
    │   ├── dyno_provider.dart
    │   └── log_provider.dart
    ├── screens/                     # Full-screen views
    │   ├── auth/
    │   ├── dashboard/
    │   ├── app_details/
    │   └── logs/
    └── widgets/                     # Reusable components
        ├── common/
        └── dialogs/
```

**Rationale**: This structure follows Flutter best practices, separates data layer from presentation, and makes testing easier.

---

### 2. State Management Approach

**Decision**: Use Provider package with ChangeNotifier pattern

**Implementation**:
- Create Provider classes for each feature (Apps, Dynos, Logs, Auth)
- Use `MultiProvider` at the root to provide all services
- Use `ChangeNotifierProvider` for mutable state
- Consume state with `context.watch<T>()` for reactive UI
- Use `context.read<T>()` for non-reactive actions (button taps)

**Example Provider**:
```dart
class AppsProvider extends ChangeNotifier {
  final AppRepository _repository;
  
  List<App> _apps = [];
  bool _isLoading = false;
  String? _error;
  
  List<App> get apps => _apps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadApps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _apps = await _repository.getApps();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**Rationale**: Provider is officially recommended, has minimal boilerplate, and integrates well with Flutter's widget tree.

---

### 3. API Service Architecture

**Decision**: Use Dio with interceptors for all HTTP communication

**Configuration**:
```dart
class HerokuApiService {
  late final Dio _dio;
  final SecureStorageService _storage;
  
  HerokuApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.heroku.com',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Accept': 'application/vnd.heroku+json; version=3',
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }
  
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }
}
```

**Features**:
- Global base URL and headers
- Automatic token injection via interceptor
- Centralized error handling
- Request/response logging (debug mode only)
- Timeout configuration
- Type-safe responses with JSON serialization

**Rationale**: Dio provides all needed features out-of-the-box, reducing custom code and improving reliability.

---

### 4. Secure Storage Strategy

**Decision**: Use flutter_secure_storage for token persistence

**Implementation**:
```dart
class SecureStorageService {
  final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  static const _tokenKey = 'heroku_api_token';
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }
}
```

**Security Considerations**:
- Use `encryptedSharedPreferences` on Android
- Never log tokens
- Clear token on logout
- Check token existence before API calls

**Rationale**: Platform-specific encryption (Keychain/KeyStore) provides secure storage without custom encryption implementation.

---

## Summary of Key Packages

Based on research, here are the essential dependencies for Phase 1:

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.0
  
  # HTTP Client
  dio: ^5.4.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Utilities
  intl: ^0.19.0  # Date formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

**Installation Command**:

```bash
flutter pub add provider dio flutter_secure_storage intl
flutter pub add -d flutter_lints
```

---

## Next Steps

### Phase 1 Implementation Checklist

1. ✅ **Research Complete** - Documentation gathered and architectural decisions made

2. **Project Setup**
   - [ ] Add dependencies to pubspec.yaml
   - [ ] Run `flutter pub get`
   - [ ] Create directory structure (lib/core, lib/data, lib/presentation)
   - [ ] Set up constants files

3. **Core Services**
   - [ ] Create `SecureStorageService` class
   - [ ] Create `HerokuApiService` with Dio configuration
   - [ ] Implement interceptors (auth, logging, error)
   - [ ] Create custom exception classes

4. **Data Models**
   - [ ] Create `App` model with JSON serialization
   - [ ] Create `Dyno` model
   - [ ] Create `Formation` model
   - [ ] Add model tests

5. **Authentication**
   - [ ] Create `AuthRepository`
   - [ ] Create `AuthProvider`
   - [ ] Build token input screen
   - [ ] Implement token validation

6. **Dashboard**
   - [ ] Create `AppRepository`
   - [ ] Create `AppsProvider`
   - [ ] Build dashboard screen with app list
   - [ ] Add pull-to-refresh
   - [ ] Implement search/filter

7. **Testing**
   - [ ] Unit tests for repositories
   - [ ] Unit tests for services
   - [ ] Widget tests for key screens

---

## References

- **Flutter Docs**: https://docs.flutter.dev
- **Provider Package**: https://pub.dev/packages/provider
- **Dio Package**: https://pub.dev/packages/dio
- **Flutter Secure Storage**: https://pub.dev/packages/flutter_secure_storage
- **Heroku Platform API**: https://devcenter.heroku.com/articles/platform-api-reference

---

**Research Status**: ✅ Complete  
**Phase 0.1 Completion**: 100%  
**Ready for Phase 1**: Yes  
**Date Completed**: November 10, 2025
