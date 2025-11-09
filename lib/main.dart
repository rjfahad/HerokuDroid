import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/app.dart';
import 'package:herokuandroid/data/repositories/addon_repository.dart';
import 'package:herokuandroid/data/repositories/app_repository.dart';
import 'package:herokuandroid/data/repositories/auth_repository.dart';
import 'package:herokuandroid/data/repositories/config_repository.dart';
import 'package:herokuandroid/data/repositories/log_repository.dart';
import 'package:herokuandroid/data/services/heroku_api_service.dart';
import 'package:herokuandroid/data/services/log_stream_service.dart';
import 'package:herokuandroid/data/services/secure_storage_service.dart';
import 'package:herokuandroid/presentation/providers/addon_provider.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';
import 'package:herokuandroid/presentation/providers/config_provider.dart';
import 'package:herokuandroid/presentation/providers/log_provider.dart';

void main() {
  // Initialize services
  final secureStorage = SecureStorageService();
  final apiService = HerokuApiService(secureStorage);
  final logStreamService = LogStreamService(
    Dio(),
  ); // Separate Dio for streaming

  // Initialize repositories
  final authRepository = AuthRepository(
    apiService: apiService,
    storageService: secureStorage,
  );
  final appRepository = AppRepository(apiService: apiService);
  final configRepository = ConfigRepository(apiService: apiService);
  final addonRepository = AddonRepository(apiService: apiService);
  final logRepository = LogRepository(
    apiService: apiService,
    streamService: logStreamService,
  );

  runApp(
    MultiProvider(
      providers: [
        // Provide AuthProvider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        // Provide AppsProvider
        ChangeNotifierProvider(
          create: (_) => AppsProvider(repository: appRepository),
        ),
        // Provide ConfigProvider
        ChangeNotifierProvider(
          create: (_) => ConfigProvider(repository: configRepository),
        ),
        // Provide AddonProvider
        ChangeNotifierProvider(
          create: (_) => AddonProvider(repository: addonRepository),
        ),
        // Provide LogProvider (depends on AuthProvider for token)
        ChangeNotifierProxyProvider<AuthProvider, LogProvider>(
          create: (_) => LogProvider(
            repository: logRepository,
            token: '', // Will be updated by proxy
          ),
          update: (_, authProvider, logProvider) {
            if (logProvider == null) {
              return LogProvider(
                repository: logRepository,
                token: authProvider.token ?? '',
              );
            }
            // Update token in existing provider
            logProvider.updateToken(authProvider.token ?? '');
            return logProvider;
          },
        ),
      ],
      child: const HerokuDroidApp(),
    ),
  );
}
