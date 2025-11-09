# Heroku Android Client - Implementation Plan

**Project**: HerokuDroid  
**Platform**: Flutter (Android)  
**Target API**: Heroku Platform API v3  
**Primary Purpose**: Monitor deployed app logs and manage Heroku resources  
**Date Created**: November 10, 2025

---

## 🎯 Project Overview

A native Android application built with Flutter to manage Heroku applications, with primary focus on log monitoring and secondary features for app management (dyno scaling, config vars, maintenance mode, add-ons).

---

## 📋 Core Features

### 1. **Heroku Dashboard**

- List all apps (with search/filter)
- Quick app status overview (dyno state, last deployment)
- Pull-to-refresh for real-time updates
- App cards showing:
  - App name
  - Region
  - Stack
  - Dyno status (up/down/idle)
  - Last release info

### 2. **App Management**

#### Dyno Management

- **Scale dynos up/down**
  - View current formation (web, worker, etc.)
  - Adjust quantity (0-N)
  - Change dyno size (standard-1X, standard-2X, etc.)
  - Real-time scaling feedback
  
- **Restart dynos**
  - Restart all dynos
  - Restart specific dyno type
  - Restart individual dyno by name
  - Confirmation dialogs to prevent accidents

#### Maintenance Mode

- **Enable/disable maintenance**
  - Toggle switch in app details
  - Visual indicator when app is in maintenance
  - Confirmation before enabling

#### Config Vars (Environment Variables)

- **View config vars**
  - List all environment variables
  - Search/filter vars
  - Copy value to clipboard
  - Mask sensitive values (toggle visibility)
  
- **Manage config vars**
  - Add new variables
  - Edit existing variables
  - Delete variables
  - Bulk edit mode

#### Add-ons

- **View installed add-ons**
  - List add-ons with plan details
  - Add-on state (provisioned, deprovisioned)
  - Pricing information
  - Quick links to add-on dashboards (open in browser)

### 3. **Log Monitoring** (PRIMARY FEATURE)

#### Real-time Logs

- **Live log streaming**
  - WebSocket or long-polling connection
  - Auto-scroll with pause option
  - Color-coded log levels (info, warn, error)
  - Timestamp display

#### Log Filters

- Filter by:
  - Source (app, heroku, router, postgres)
  - Dyno type (web, worker)
  - Specific dyno instance
  - Log level
  - Time range
  - Custom text search

#### Log Features

- **Copy log lines**
- **Share logs** (export to file/email)
- **Bookmark important logs**
- **Log history** (last N lines before connection)
- **Tail -n option** (choose number of lines)
- **Auto-reconnect** on connection loss

---

## 🏗️ Technical Architecture

### Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # API URLs, headers
│   │   ├── app_constants.dart       # App config
│   │   └── theme_constants.dart     # Colors, text styles
│   ├── errors/
│   │   └── heroku_exception.dart    # Custom exceptions
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── log_parser.dart
│   │   └── validators.dart
│   └── routes/
│       └── app_routes.dart          # Navigation routes
│
├── data/
│   ├── models/
│   │   ├── app.dart                 # Heroku app model
│   │   ├── dyno.dart
│   │   ├── formation.dart
│   │   ├── config_var.dart
│   │   ├── addon.dart
│   │   ├── release.dart
│   │   ├── log_entry.dart
│   │   └── log_session.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── app_repository.dart
│   │   ├── dyno_repository.dart
│   │   ├── config_repository.dart
│   │   ├── addon_repository.dart
│   │   └── log_repository.dart
│   └── services/
│       ├── heroku_api_service.dart  # HTTP client wrapper
│       ├── secure_storage_service.dart
│       └── log_stream_service.dart  # WebSocket/SSE handler
│
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── token_input_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── app_details/
│   │   │   ├── app_details_screen.dart
│   │   │   └── widgets/
│   │   │       ├── dyno_list_widget.dart
│   │   │       ├── config_vars_widget.dart
│   │   │       └── addons_widget.dart
│   │   ├── dyno_management/
│   │   │   ├── scale_dyno_screen.dart
│   │   │   └── restart_dyno_screen.dart
│   │   ├── config_vars/
│   │   │   ├── config_vars_screen.dart
│   │   │   └── edit_config_var_screen.dart
│   │   └── logs/
│   │       ├── logs_screen.dart
│   │       └── widgets/
│   │           ├── log_viewer_widget.dart
│   │           ├── log_filter_widget.dart
│   │           └── log_entry_widget.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── app_card.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── empty_state_widget.dart
│   │   └── dialogs/
│   │       ├── confirmation_dialog.dart
│   │       └── info_dialog.dart
│   └── providers/
│       ├── auth_provider.dart
│       ├── apps_provider.dart
│       ├── dyno_provider.dart
│       ├── config_provider.dart
│       └── log_provider.dart
│
└── tests/
    ├── unit/
    ├── widget/
    └── integration/
```

### Dependencies (pubspec.yaml additions)

```yaml
dependencies:
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0                    # Alternative HTTP client with interceptors
  
  # State Management
  provider: ^6.1.0               # Or riverpod/bloc based on preference
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # UI/UX
  flutter_slidable: ^3.0.0       # Swipe actions
  pull_to_refresh: ^2.0.0
  shimmer: ^3.0.0                # Loading skeletons
  
  # Real-time/Logs
  web_socket_channel: ^2.4.0     # WebSocket for log streaming
  
  # Utilities
  intl: ^0.19.0                  # Date formatting
  share_plus: ^7.2.0             # Share logs
  url_launcher: ^6.2.0           # Open add-on dashboards
  
  # Local caching (optional)
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0      # For model serialization
```

---

## 🔐 Authentication Strategy

### Option 1: API Token (Simpler - Recommended for MVP)

1. User inputs Heroku API token manually
2. Token stored in `flutter_secure_storage`
3. Token included in all API requests as `Authorization: Bearer <token>`

**Token Generation Instructions (in-app):**

```bash
heroku authorizations:create --description "HerokuDroid Android App"
# Or
heroku auth:token
```

### Option 2: OAuth 2.0 (Production-grade)

1. Register OAuth app with Heroku
2. Implement Authorization Code flow
3. Store access/refresh tokens securely
4. Auto-refresh on expiry

**OAuth Flow:**

- Redirect to Heroku OAuth page
- User authorizes app
- Receive authorization code
- Exchange for access token
- Store tokens securely

---

## 📱 Screen Designs & User Flow

### 1. **Splash/Auth Flow**

```
Splash Screen
    ↓
Check for stored token
    ↓
    ├─ Token exists → Dashboard
    └─ No token → Token Input Screen
```

### 2. **Dashboard Screen**

- **AppBar**: "HerokuDroid" title, refresh icon, settings icon
- **Body**:
  - Search bar (filter apps)
  - App cards grid/list
  - Pull-to-refresh
- **FloatingActionButton**: Quick actions menu (create app, view account)

**App Card Contents:**

- App icon/initial
- App name
- Region badge
- Dyno status dots (green/yellow/red)
- Last deployed time
- Tap → Navigate to App Details

### 3. **App Details Screen**

- **AppBar**: App name, more actions (delete, transfer)
- **Tabs**:
  1. **Overview**
     - Quick stats
     - Git URL (copy button)
     - Web URL (open button)
     - Release info
     - Maintenance toggle
  
  2. **Dynos**
     - Formation list (web: 2, worker: 1)
     - Scale buttons (+/-)
     - Restart buttons
     - Dyno size selector
  
  3. **Config**
     - Config vars list (key-value pairs)
     - Add/Edit/Delete actions
     - Search filter
  
  4. **Add-ons**
     - Installed add-ons list
     - Plan details
     - Open dashboard buttons
  
  5. **Logs** (PRIMARY)
     - Live log viewer (see below)

### 4. **Logs Screen (Detailed)**

- **AppBar**:
  - App name
  - Filter icon
  - Share icon
  - Connection status indicator
  
- **Filter Panel** (collapsible):
  - Source dropdown (all, app, heroku, router)
  - Dyno dropdown
  - Log level chips
  - Tail -n input
  - Time range picker
  
- **Log Viewer**:
  - Auto-scrolling list
  - Timestamped entries
  - Color-coded (info=white, warn=yellow, error=red)
  - Monospace font
  - Pause/resume button (FAB)
  - Copy individual log line (long-press)
  
- **Bottom Bar**:
  - Connection status
  - Log count
  - Clear logs button

### 5. **Scale Dyno Screen**

- Dyno type selector
- Current: `web: 2 x standard-1X`
- Quantity slider (0-10)
- Size dropdown (hobby, standard-1X, standard-2X, etc.)
- Estimated cost display
- Scale button

### 6. **Config Vars Screen**

- Search bar
- List of key-value pairs
- Add button (FAB)
- Edit/Delete (swipe actions)
- Masked values with toggle visibility

---

## 🔌 API Integration Plan

### Heroku API Client Service

```dart
class HerokuApiService {
  static const String baseUrl = 'https://api.heroku.com';
  static const String acceptHeader = 'application/vnd.heroku+json; version=3';
  
  final Dio _dio;
  final SecureStorageService _storage;
  
  // Methods:
  // - setAuthToken(String token)
  // - Future<List<App>> getApps()
  // - Future<App> getApp(String appId)
  // - Future<List<Dyno>> getDynos(String appId)
  // - Future<void> restartDynos(String appId, {String? dyno})
  // - Future<Formation> scaleFormation(String appId, String type, int quantity)
  // - Future<Map<String, String>> getConfigVars(String appId)
  // - Future<void> updateConfigVars(String appId, Map<String, String> vars)
  // - Future<List<Addon>> getAddons(String appId)
  // - Future<App> setMaintenance(String appId, bool enabled)
  // - Future<LogSession> createLogSession(String appId, {filters})
}
```

### Log Streaming Service

```dart
class LogStreamService {
  WebSocketChannel? _channel;
  StreamController<LogEntry> _logController = StreamController.broadcast();
  
  // Methods:
  // - Future<void> connect(String logSessionUrl)
  // - Stream<LogEntry> get logStream
  // - void disconnect()
  // - void pause() / resume()
}
```

---

## 🎨 UI/UX Considerations

### Theme

- **Primary Color**: Heroku purple (#6567A5 or #430098)
- **Accent Color**: Complementary (orange/yellow for warnings)
- **Dark Mode**: Support dark theme for log viewing

### Animations

- Smooth transitions between screens
- Loading skeletons while fetching
- Success/error snackbars with animations
- Dyno status pulse animation

### Accessibility

- Large touch targets (min 48x48)
- High contrast text
- Screen reader support
- Haptic feedback for critical actions

---

## 🚀 Implementation Phases

### **Phase 0.1: Documentation Research - Foundation**

**Duration**: 1 day

**Objective**: Research Flutter best practices, secure storage, and HTTP client setup

- [x] Use Context7 MCP to fetch Flutter documentation
  - Topic: "project structure and architecture patterns"
  - Topic: "state management with provider"
  - Topic: "http client and API integration"
- [x] Use Context7 MCP to fetch flutter_secure_storage documentation
  - Topic: "storing sensitive tokens securely"
  - Topic: "Android keystore integration"
- [x] Use Context7 MCP to fetch dio or http package documentation
  - Topic: "interceptors and authentication headers"
  - Topic: "error handling and retry logic"
- [x] Document findings in `docs/research_phase1.md`

**Deliverable**: ✅ Research notes and architectural decisions document completed

**Status**: ✅ COMPLETE (November 10, 2025)

---

### **Phase 1: Foundation (Week 1-2)**

- [x] Set up Flutter project structure
- [x] Implement secure token storage
- [x] Create Heroku API service with basic endpoints
- [x] Build authentication flow (token input)
- [x] Create data models (App, Dyno, Formation)
- [x] Implement dashboard with app list
- [x] Basic error handling

**Deliverable**: ✅ Login + view list of apps

**Status**: ✅ COMPLETE (November 10, 2025)

---

### **Phase 0.2: Documentation Research - Dyno Management**

**Duration**: 1 day

**Objective**: Research Heroku dyno concepts, formation scaling, and Flutter UI patterns

- [ ] Use Context7 MCP to fetch Heroku Platform API docs
  - Topic: "dyno management and formation endpoints"
  - Topic: "dyno types and sizes"
  - Topic: "restart and scale operations"
- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "bottom sheets and dialogs"
  - Topic: "sliders and form inputs"
  - Topic: "confirmation patterns"
- [ ] Use Context7 MCP to fetch Material Design docs
  - Topic: "cards and lists"
  - Topic: "tabs navigation"
- [ ] Document API endpoints and UI patterns in `docs/research_phase2.md`

**Deliverable**: Dyno management API reference and UI mockup decisions

---

### **Phase 2: App Details & Dyno Management (Week 3-4)**

- [ ] App details screen with tabs
- [ ] Dyno list display
- [ ] Scale dyno functionality
- [ ] Restart dyno functionality
- [ ] Maintenance mode toggle
- [ ] Formation management UI
- [ ] Add confirmation dialogs

**Deliverable**: Full dyno management capabilities

---

### **Phase 0.3: Documentation Research - Config & Add-ons**

**Duration**: 1 day

**Objective**: Research config vars API, secure input handling, and Flutter forms

- [ ] Use Context7 MCP to fetch Heroku Platform API docs
  - Topic: "config vars CRUD operations"
  - Topic: "add-ons listing and management"
- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "form validation and text input"
  - Topic: "search and filter patterns"
  - Topic: "masked input fields"
- [ ] Use Context7 MCP to fetch flutter_slidable or similar packages
  - Topic: "swipe actions for list items"
- [ ] Document config vars API and form patterns in `docs/research_phase3.md`

**Deliverable**: Config management API reference and form validation strategy

---

### **Phase 3: Config Vars & Add-ons (Week 5)**

- [ ] Config vars list screen
- [ ] Add/edit/delete config vars
- [ ] Search and filter config vars
- [ ] Value masking/unmasking
- [ ] Add-ons list display
- [ ] Open add-on dashboard in browser

**Deliverable**: Complete config and add-on management

---

### **Phase 0.4: Documentation Research - Log Streaming** ⭐

**Duration**: 2 days (critical feature)

**Objective**: Deep dive into log streaming, WebSocket/SSE, and real-time UI updates

- [ ] Use Context7 MCP to fetch Heroku Platform API docs
  - Topic: "log sessions and log streaming"
  - Topic: "logplex URL and authentication"
  - Topic: "log drain formats and filters"
- [ ] Use Context7 MCP to fetch web_socket_channel documentation
  - Topic: "WebSocket connection and reconnection"
  - Topic: "stream handling and error recovery"
- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "StreamBuilder and real-time updates"
  - Topic: "auto-scrolling ListView"
  - Topic: "text styling and monospace fonts"
- [ ] Use Context7 MCP to research SSE (Server-Sent Events) alternatives
  - Topic: "SSE vs WebSocket for log streaming"
- [ ] Document streaming architecture in `docs/research_phase4.md`

**Deliverable**: Log streaming architecture design and connection strategy

---

### **Phase 4: Log Monitoring (Week 6-7)** ⭐ PRIMARY

- [ ] Create log session via API
- [ ] Implement WebSocket/SSE log streaming
- [ ] Build log viewer UI with auto-scroll
- [ ] Color-coded log levels
- [ ] Log filtering (source, dyno, level)
- [ ] Pause/resume functionality
- [ ] Copy/share logs
- [ ] Connection status indicators
- [ ] Auto-reconnect logic

**Deliverable**: Real-time log monitoring

---

### **Phase 0.5: Documentation Research - Testing & Polish**

**Duration**: 1 day

**Objective**: Research Flutter testing patterns and UI polish techniques

- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "unit testing and mockito"
  - Topic: "widget testing patterns"
  - Topic: "integration testing"
- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "pull to refresh patterns"
  - Topic: "shimmer loading effects"
  - Topic: "dark mode theming"
- [ ] Use Context7 MCP to fetch Material Design docs
  - Topic: "loading states and skeletons"
  - Topic: "snackbar and toast patterns"
- [ ] Document testing strategy in `docs/research_phase5.md`

**Deliverable**: Testing framework setup and polish guidelines

---

### **Phase 5: Polish & Testing (Week 8)**

- [ ] Add pull-to-refresh everywhere
- [ ] Implement search for apps
- [ ] Add loading states and skeletons
- [ ] Error handling improvements
- [ ] Write unit tests (repositories, services)
- [ ] Widget tests for key screens
- [ ] Integration tests for critical flows
- [ ] Performance optimization (caching, pagination)
- [ ] Dark mode support
- [ ] App icon and splash screen

**Deliverable**: Production-ready app

---

### **Phase 0.6: Documentation Research - Advanced Features (Optional)**

**Duration**: 1-2 days

**Objective**: Research OAuth, push notifications, and advanced Flutter features

- [ ] Use Context7 MCP to fetch Heroku Platform API docs
  - Topic: "OAuth 2.0 flow and token management"
  - Topic: "webhooks for deployment notifications"
- [ ] Use Context7 MCP to fetch Flutter documentation
  - Topic: "Firebase Cloud Messaging for push notifications"
  - Topic: "background services and WorkManager"
  - Topic: "multi-account architecture"
- [ ] Use Context7 MCP to fetch chart/graphing packages
  - Topic: "fl_chart for metrics visualization"
- [ ] Document advanced features architecture in `docs/research_phase6.md`

**Deliverable**: Advanced features roadmap and technical approach

---

### **Phase 6: Advanced Features (Optional)**

- [ ] OAuth 2.0 authentication
- [ ] Push notifications (deployment alerts)
- [ ] Build/release management
- [ ] Multiple account support
- [ ] Offline mode with caching
- [ ] Log export to file
- [ ] Custom log alerts/triggers
- [ ] App metrics/monitoring graphs
- [ ] Team collaboration features

---

## 🧪 Testing Strategy

### Unit Tests

- API service methods
- Data model serialization
- Business logic in repositories
- Utility functions (parsers, validators)

### Widget Tests

- App card rendering
- Log viewer behavior
- Config var CRUD operations
- Dyno scaling UI

### Integration Tests

- Login → Dashboard → App Details flow
- Dyno scaling end-to-end
- Log streaming connection
- Config var updates

### Manual Testing

- Real Heroku apps
- Various network conditions
- Different dyno types and sizes
- Edge cases (no apps, no logs, errors)

---

## 🔒 Security Considerations

1. **Token Storage**
   - Use `flutter_secure_storage` (encrypted keystore)
   - Never log tokens
   - Clear on logout

2. **Network Security**
   - HTTPS only (enforced)
   - Certificate pinning (optional)
   - Timeout handling

3. **Input Validation**
   - Sanitize config var inputs
   - Validate API responses
   - Rate limiting on client side

4. **Permissions**
   - Minimal Android permissions
   - Request internet permission only

---

## 📊 Success Metrics

- **Performance**: App launch < 2s, API calls < 1s avg
- **Reliability**: Log stream uptime > 95%
- **Usability**: Complete primary task (view logs) in < 3 taps
- **Coverage**: Unit test coverage > 80%

---

## 🛠️ Development Tools

- **IDE**: VS Code / Android Studio
- **Version Control**: Git
- **API Testing**: Postman / Insomnia
- **Design**: Figma (optional for mockups)
- **CI/CD**: GitHub Actions (optional)

---

## 📝 Notes & Assumptions

- App targets Android 7.0+ (API 24+)
- User has existing Heroku account and apps
- User can generate API token via Heroku CLI
- Primary use case: monitoring production apps
- Single user (no multi-account initially)

---

## 🔗 Resources

- [Heroku Platform API Docs](https://devcenter.heroku.com/articles/platform-api-reference)
- [Flutter Documentation](https://docs.flutter.dev)
- [Material Design Guidelines](https://m3.material.io)
- API Token: `heroku auth:token`

---

## ✅ Next Immediate Steps

1. **Review and approve this plan**
2. **Start Phase 0.1: Documentation Research - Foundation**
   - Use Context7 MCP to research Flutter architecture
   - Research secure storage best practices
   - Research HTTP client setup with authentication
3. **Create `docs/` directory** for research documentation
4. **Set up project dependencies** (run `flutter pub add` for packages)
5. **Create data models** (App, Dyno, Formation, ConfigVar, Addon, LogEntry)
6. **Build HerokuApiService** with authentication
7. **Implement Dashboard screen** with app listing
8. **Start Phase 1 development**

### Documentation Research Workflow

Before starting each main phase:

1. **Identify topics** to research (listed in Phase 0.x)
2. **Use Context7 MCP tools** to fetch relevant documentation:
   ```
   - mcp_upstash_conte_resolve-library-id (find library)
   - mcp_upstash_conte_get-library-docs (fetch docs)
   ```
3. **Document findings** in `docs/research_phaseX.md`
4. **Make architectural decisions** based on research
5. **Proceed with implementation** in main phase

---

**Document Version**: 1.1  
**Last Updated**: November 10, 2025  
**Status**: Updated - Documentation-First Approach
