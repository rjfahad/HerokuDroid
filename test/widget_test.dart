// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokuandroid/app.dart';
import 'package:herokuandroid/data/repositories/app_repository.dart';
import 'package:herokuandroid/data/repositories/auth_repository.dart';
import 'package:herokuandroid/data/services/heroku_api_service.dart';
import 'package:herokuandroid/data/services/secure_storage_service.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HerokuDroid app smoke test', (WidgetTester tester) async {
    // Initialize services
    final secureStorage = SecureStorageService();
    final apiService = HerokuApiService(secureStorage);

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
          ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => AppsProvider(repository: appRepository),
          ),
        ],
        child: const HerokuDroidApp(),
      ),
    );

    // Verify that the login screen is shown (since we're not authenticated)
    expect(find.text('HerokuDroid'), findsOneWidget);
    expect(find.text('API Token'), findsOneWidget);
  });
}
