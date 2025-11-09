import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/app.dart';
import 'package:herokuandroid/data/repositories/app_repository.dart';
import 'package:herokuandroid/data/repositories/auth_repository.dart';
import 'package:herokuandroid/data/services/heroku_api_service.dart';
import 'package:herokuandroid/data/services/secure_storage_service.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';

void main() {
  // Initialize services
  final secureStorage = SecureStorageService();
  final apiService = HerokuApiService(secureStorage);

  // Initialize repositories
  final authRepository = AuthRepository(
    apiService: apiService,
    storageService: secureStorage,
  );
  final appRepository = AppRepository(apiService: apiService);

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
      ],
      child: const HerokuDroidApp(),
    ),
  );
}
