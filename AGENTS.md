# HerokuDroid — Agent Notes

Flutter Android app (also iOS/web/desktop scaffolds) that manages Heroku apps via
the Heroku Platform API v3. Primary feature: real-time log streaming. Login is by
Heroku API key — there is no sign-up of our own.

Package name is `herokudroid` (imports use `package:herokudroid/...`); Android
application id is `com.phoenixdev.herokudroid`.

## Commands

```bash
flutter pub get
flutter analyze                 # lint (flutter_lints via analysis_options.yaml)
flutter test                    # all tests
flutter test test/unit/models/app_test.dart   # single file
dart format .                   # NOT `flutter format` (removed)
flutter run
flutter build apk --release     # also: --split-per-abi, `appbundle --release`
dart run flutter_launcher_icons # after changing assets/images/logo_icon.png
dart run build_runner build     # only if you add @GenerateMocks / codegen
```

VS Code build tasks mirror the release build/split/appbundle commands (`.vscode/tasks.json`).

## Architecture

3-layer: `presentation/` → `data/repositories/` → `data/services/`.

- **DI lives only in `lib/main.dart`** — every service/repository/provider is
  constructed there and injected via constructor. There is no service locator.
  When adding a feature, register its provider in the `MultiProvider` list in
  `main.dart` or it is unreachable.
- `data/services/heroku_api_service.dart` is the single Dio client. Its auth
  interceptor injects the token, its error interceptor converts `DioException`
  → `HerokuException`. Repositories catch/rethrow `HerokuException`; providers
  surface `e.message`.
- All API paths are static methods on `ApiConstants` (`lib/core/constants/api_constants.dart`).
  Add new endpoints there, never inline strings.
- No routing package. Navigation is imperative `Navigator`; `AuthCheck` in
  `lib/app.dart` chooses login vs dashboard. Use `pushReplacement` for
  login→dashboard, `push` otherwise.

Providers follow a strict shape: private state + public getters (no setters),
`notifyListeners()` after each change and again in `finally`. `LogProvider` is
special: wired with `ChangeNotifierProxyProvider<AuthProvider, LogProvider>` so
it receives the current token via `updateToken`.

## Heroku API quirks

- Nested fields: `json['region']['name']` → read as `json['region']?['name']`.
- Config vars are a flat `Map<String, String>`, not a list.
- Scaling is `PATCH /apps/{id}/formation/{type}` with `{quantity, size}`.
- **Log streaming is HTTP, not WebSocket**: `POST /apps/{id}/log-sessions`
  returns `logplex_url`, then `LogStreamService` opens a Dio
  `ResponseType.stream` and line-buffers bytes. Do not "fix" this to WebSocket.

## UI: "Design B (Paper)" theme

The active design system is Paper, under `lib/core/theme/` (`paper_theme.dart`,
`paper_colors.dart`, `paper_tokens.dart`). Reuse the shared widgets in
`lib/presentation/widgets/paper/` (`PaperCard`, `paper_snack`, `paper_states`,
`swipe_reveal`) and read colors via the `context.paper` extension. `PaperTheme.light`/`dark`
are set in `lib/app.dart`. Prefer Paper for all new UI.

`lib/core/constants/theme_constants.dart` is legacy and only still used by
`widgets/common/empty_state_widget.dart` — do not extend it.

Loading uses `skeletonizer`; lists use `RefreshIndicator`.

## Security

- API token lives in `flutter_secure_storage`. Never log or expose it — the Dio
  logging interceptor deliberately excludes the `Authorization` header.
- Optional biometric/PIN **app lock** (`AppLockService`/`AppLockProvider`,
  `screens/auth/lock_screen.dart`). Password is stored only as a salted+iterated
  SHA-256 hash in secure storage. `AuthCheck` gates on it and re-locks on
  `AppLifecycleState.paused`. `local_auth` has hard platform requirements that
  will crash biometrics if reverted: `MainActivity` must extend
  `FlutterFragmentActivity`, `AndroidManifest.xml` needs `USE_BIOMETRIC`, the
  Android `LaunchTheme` parent must be a `Theme.AppCompat.*` theme, and iOS needs
  `NSFaceIDUsageDescription`.
- `android/key.properties` and `android/app/upload-keystore.jks` are gitignored
  (verify with `git check-ignore`). Release signing falls back to debug keys when
  `key.properties` is absent, so `flutter run --release` still works locally.

## Legal pages

`docs/` is a GitHub Pages (Jekyll) site with `privacy`/`terms`. The app opens
`LegalUrls.privacy` / `LegalUrls.terms` (`lib/core/constants/legal_urls.dart`).
Root `PRIVACY.md` / `TERMS.md` and `docs/privacy.md` / `docs/terms.md` duplicate
each other — keep both in sync.

## Tests

`test/` mirrors `lib/`. Unit tests cover models; widget tests cover a few common
widgets plus a smoke test in `test/widget_test.dart` (uses
`SharedPreferences.setMockInitialValues({})`). No mocked repositories exist yet
despite `mockito`/`build_runner` being dev deps.

## Known limitations

No log auto-reconnect (`LogProvider` asks the user to reconnect on token change),
logs capped at 1000 entries (`LogProvider._maxLogs`), no token refresh (re-login
required). Heroku rate-limit (429) maps to a friendly message but there is no
retry/backoff.

## Stale docs warning

`.github/copilot-instructions.md` has useful pattern detail but references files
that no longer exist (`IMPLEMENTATION_PLAN.md`, `docs/research_phase*.md`,
`lib/core/utils/`). Trust the code and this file over it.
