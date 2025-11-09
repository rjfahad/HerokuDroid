import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokuandroid/app.dart';
import 'package:herokuandroid/data/repositories/app_repository.dart';
import 'package:herokuandroid/data/repositories/auth_repository.dart';
import 'package:herokuandroid/data/services/cache_service.dart';
import 'package:herokuandroid/data/services/heroku_api_service.dart';
import 'package:herokuandroid/data/services/secure_storage_service.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';
import 'package:herokuandroid/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('HerokuDroid app smoke test', (WidgetTester tester) async {
    // Initialize shared preferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize services
    final secureStorage = SecureStorageService();
    final apiService = HerokuApiService(secureStorage);
    final cacheService = CacheService(prefs);

    // Initialize repositories
    final authRepository = AuthRepository(
      apiService: apiService,
      storageService: secureStorage,
    );
    final appRepository = AppRepository(apiService: apiService);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => AppsProvider(
              repository: appRepository,
              cacheService: cacheService,
            ),
          ),
        ],
        child: const HerokuDroidApp(),
      ),
    );

    // Wait for a single frame
    await tester.pump();

    // Verify basic UI elements exist
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
