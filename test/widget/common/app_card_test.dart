import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/data/repositories/addon_repository.dart';
import 'package:herokudroid/data/repositories/app_repository.dart';
import 'package:herokudroid/data/repositories/config_repository.dart';
import 'package:herokudroid/data/repositories/formation_repository.dart';
import 'package:herokudroid/data/repositories/log_repository.dart';
import 'package:herokudroid/data/services/cache_service.dart';
import 'package:herokudroid/data/services/heroku_api_service.dart';
import 'package:herokudroid/data/services/log_stream_service.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';
import 'package:herokudroid/presentation/providers/addon_provider.dart';
import 'package:herokudroid/presentation/providers/apps_provider.dart';
import 'package:herokudroid/presentation/providers/config_provider.dart';
import 'package:herokudroid/presentation/providers/dyno_provider.dart';
import 'package:herokudroid/presentation/providers/log_provider.dart';
import 'package:herokudroid/presentation/providers/release_provider.dart';
import 'package:herokudroid/presentation/screens/app_details/app_details_screen.dart';
import 'package:herokudroid/presentation/widgets/common/app_card.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

void main() {
  group('AppCard Widget Tests', () {
    late App testApp;
    late App minimalApp;
    late App runningApp;
    late App stoppedApp;

    setUp(() {
      testApp = App(
        id: 'test-app-id-123',
        name: 'my-test-app',
        region: 'us',
        stack: 'heroku-22',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        maintenance: false,
      );

      runningApp = App(
        id: 'running-app-id',
        name: 'running-app',
        region: 'eu',
        stack: 'heroku-24',
        totalDynos: 3,
        runningDynos: 2,
      );

      stoppedApp = App(
        id: 'stopped-app-id',
        name: 'stopped-app',
        region: 'us',
        stack: 'heroku-22',
        totalDynos: 0,
        runningDynos: 0,
      );

      minimalApp = App(id: 'minimal-app-id', name: 'minimal-app');
    });

    Widget wrap(Widget child) =>
        MaterialApp(home: Scaffold(body: child));

    testWidgets('renders app name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(AppCard(app: testApp)));
      expect(find.text('my-test-app'), findsOneWidget);
    });

    testWidgets('shows region and stack in the meta line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(AppCard(app: testApp)));
      expect(find.textContaining('us'), findsWidgets);
      expect(find.textContaining('heroku-22'), findsWidgets);
    });

    testWidgets('renders a PaperCard surface', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(AppCard(app: testApp)));
      expect(find.byType(PaperCard), findsWidgets);
    });

    testWidgets('shows running tag when dynos are up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(AppCard(app: runningApp)));
      expect(find.text('running'), findsOneWidget);
    });

    testWidgets('shows stopped tag when scaled to zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(AppCard(app: stoppedApp)));
      expect(find.text('stopped'), findsOneWidget);
    });

    testWidgets('hides status tag when dyno data is unknown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(AppCard(app: testApp)));
      expect(find.text('running'), findsNothing);
      expect(find.text('stopped'), findsNothing);
    });

    testWidgets('handles minimal app with no optional fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(AppCard(app: minimalApp)));
      expect(find.text('minimal-app'), findsOneWidget);
      expect(find.text('running'), findsNothing);
      expect(find.text('stopped'), findsNothing);
    });

    testWidgets('grid variant renders name', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(AppCard(app: testApp, isGridView: true)));
      expect(find.text('my-test-app'), findsOneWidget);
    });

    testWidgets('text overflow is handled with ellipsis', (
      WidgetTester tester,
    ) async {
      final longNameApp = App(
        id: 'long-name-app',
        name: 'this-is-a-very-long-app-name-that-should-be-truncated',
        region: 'us',
        stack: 'heroku-22',
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 300,
            child: AppCard(app: longNameApp),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('this-is-a-very-long-app-name-that-should-be-truncated'),
      );

      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });

    testWidgets('navigates to AppDetailsScreen when tapped', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final secureStorage = SecureStorageService();
      final apiService = HerokuApiService(secureStorage);
      final cacheService = CacheService(prefs);
      final appRepository = AppRepository(apiService: apiService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AppsProvider(
                repository: appRepository,
                cacheService: cacheService,
                prefs: prefs,
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => DynoProvider(FormationRepository(apiService)),
            ),
            ChangeNotifierProvider(
              create: (_) => ConfigProvider(
                repository: ConfigRepository(apiService: apiService),
                cacheService: cacheService,
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => AddonProvider(
                repository: AddonRepository(apiService: apiService),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => ReleaseProvider(
                repository: appRepository,
                cacheService: cacheService,
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => LogProvider(
                repository: LogRepository(
                  apiService: apiService,
                  streamService: LogStreamService(Dio()),
                ),
                token: '',
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: AppCard(app: testApp)),
          ),
        ),
      );

      await tester.tap(find.byType(AppCard));
      await tester.pumpAndSettle();

      expect(find.byType(AppDetailsScreen), findsOneWidget);
    });
  });
}
