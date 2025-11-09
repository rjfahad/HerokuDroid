import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokuandroid/data/models/app.dart';
import 'package:herokuandroid/presentation/widgets/common/app_card.dart';
import 'package:herokuandroid/presentation/screens/app_details/app_details_screen.dart';

void main() {
  group('AppCard Widget Tests', () {
    late App testApp;
    late App maintenanceApp;
    late App minimalApp;

    setUp(() {
      // Create test app with all fields
      testApp = App(
        id: 'test-app-id-123',
        name: 'my-test-app',
        region: 'us',
        stack: 'heroku-22',
        createdAt: DateTime(2024, 1, 15),
        maintenance: false,
      );

      // Create app in maintenance mode
      maintenanceApp = App(
        id: 'maintenance-app-id',
        name: 'maintenance-app',
        region: 'eu',
        stack: 'heroku-20',
        createdAt: DateTime(2023, 6, 1),
        maintenance: true,
      );

      // Create minimal app with only required fields
      minimalApp = App(
        id: 'minimal-app-id',
        name: 'minimal-app',
        region: null,
        stack: null,
        createdAt: null,
        maintenance: null,
      );
    });

    testWidgets('renders app name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.text('my-test-app'), findsOneWidget);
    });

    testWidgets('displays region when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.text('us'), findsOneWidget);
    });

    testWidgets('does not display region when null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: minimalApp)),
        ),
      );

      // Should find the app name but not a region
      expect(find.text('minimal-app'), findsOneWidget);
      expect(find.text('us'), findsNothing);
    });

    testWidgets('shows maintenance badge when in maintenance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: maintenanceApp)),
        ),
      );

      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.byIcon(Icons.construction), findsOneWidget);
    });

    testWidgets('does not show maintenance badge when not in maintenance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.text('Maintenance'), findsNothing);
      expect(find.byIcon(Icons.construction), findsNothing);
    });

    testWidgets('displays stack icon and label when available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.text('heroku-22'), findsOneWidget);
      expect(find.byIcon(Icons.layers), findsOneWidget);
    });

    testWidgets('displays created date when available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      // Should display formatted date
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      // Date format is "Jan 15, 2024"
      expect(find.textContaining('Jan'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('displays app icon with first letter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      // Should show 'M' from 'my-test-app'
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('navigates to AppDetailsScreen when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(AppCard));
      await tester.pumpAndSettle();

      // Verify navigation to AppDetailsScreen
      expect(find.byType(AppDetailsScreen), findsOneWidget);
    });

    testWidgets('card has proper InkWell ripple effect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('handles minimal app with no optional fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: minimalApp)),
        ),
      );

      // Should display the name
      expect(find.text('minimal-app'), findsOneWidget);

      // Should not display optional fields
      expect(find.byIcon(Icons.layers), findsNothing); // no stack
      expect(find.byIcon(Icons.calendar_today), findsNothing); // no date
      expect(find.text('Maintenance'), findsNothing); // not in maintenance
    });

    testWidgets('has Card widget as root', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppCard(app: testApp)),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('text overflow is handled with ellipsis', (
      WidgetTester tester,
    ) async {
      final longNameApp = App(
        id: 'long-name-app',
        name: 'this-is-a-very-long-app-name-that-should-be-truncated',
        region: 'us',
        stack: 'heroku-22',
        createdAt: DateTime.now(),
        maintenance: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrain width to force overflow
              child: AppCard(app: longNameApp),
            ),
          ),
        ),
      );

      // Find the Text widget with the app name
      final textWidget = tester.widget<Text>(
        find.text('this-is-a-very-long-app-name-that-should-be-truncated'),
      );

      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });
  });
}
