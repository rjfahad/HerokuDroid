import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herokudroid/app.dart';
import 'package:herokudroid/data/repositories/addon_repository.dart';
import 'package:herokudroid/data/repositories/app_repository.dart';
import 'package:herokudroid/data/repositories/auth_repository.dart';
import 'package:herokudroid/data/repositories/config_repository.dart';
import 'package:herokudroid/data/repositories/formation_repository.dart';
import 'package:herokudroid/data/repositories/log_repository.dart';
import 'package:herokudroid/data/services/app_lock_service.dart';
import 'package:herokudroid/data/services/cache_service.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';
import 'package:herokudroid/data/services/log_stream_service.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';
import 'package:herokudroid/data/services/update_service.dart';
import 'package:herokudroid/presentation/providers/addon_provider.dart';
import 'package:herokudroid/presentation/providers/app_lock_provider.dart';
import 'package:herokudroid/presentation/providers/apps_provider.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/providers/config_provider.dart';
import 'package:herokudroid/presentation/providers/dyno_provider.dart';
import 'package:herokudroid/presentation/providers/log_provider.dart';
import 'package:herokudroid/presentation/providers/release_provider.dart';
import 'package:herokudroid/presentation/providers/theme_provider.dart';
import 'package:herokudroid/presentation/providers/update_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService();
  final apiService = HerokuApiService(secureStorage);
  final cacheService = CacheService(prefs);
  final logStreamService = LogStreamService(Dio());
  final appLockService = AppLockService(storage: secureStorage);
  final updateService = UpdateService();

  final authRepository = AuthRepository(
    apiService: apiService,
    storageService: secureStorage,
  );
  final appRepository = AppRepository(apiService: apiService);
  final configRepository = ConfigRepository(apiService: apiService);
  final addonRepository = AddonRepository(apiService: apiService);
  final formationRepository = FormationRepository(apiService);
  final logRepository = LogRepository(
    apiService: apiService,
    streamService: logStreamService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => UpdateProvider(service: updateService, prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AppLockProvider(service: appLockService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AppsProvider(
            repository: appRepository,
            cacheService: cacheService,
            prefs: prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConfigProvider(
            repository: configRepository,
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AddonProvider(repository: addonRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DynoProvider(formationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReleaseProvider(
            repository: appRepository,
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LogProvider>(
          create: (_) => LogProvider(repository: logRepository, token: ''),
          update: (_, authProvider, logProvider) {
            if (logProvider == null) {
              return LogProvider(
                repository: logRepository,
                token: authProvider.token ?? '',
              );
            }
            logProvider.updateToken(authProvider.token ?? '');
            return logProvider;
          },
        ),
      ],
      child: const HerokuDroidApp(),
    ),
  );
}
