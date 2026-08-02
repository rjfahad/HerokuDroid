import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/presentation/widgets/common/error_widget.dart'
    as custom;

void main() {
  group('ErrorWidget Tests', () {
    testWidgets('displays error message', (WidgetTester tester) async {
      const testMessage = 'Failed to load data';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: testMessage)),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('displays error icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: 'Error occurred')),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays "Error" title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: custom.ErrorWidget(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('displays retry button when callback provided', (
      WidgetTester tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom.ErrorWidget(
              message: 'Network error',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, true);
    });

    testWidgets('does not display retry button when callback is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: 'Error occurred')),
        ),
      );

      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('widget is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: 'Error')),
        ),
      );

      // Check that Center widget is used (may be more than one due to widget tree)
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('calls retry callback when button tapped', (
      WidgetTester tester,
    ) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom.ErrorWidget(
              message: 'Failed to load',
              onRetry: () {
                retryCount++;
              },
            ),
          ),
        ),
      );

      // Tap retry button multiple times
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryCount, 1);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryCount, 2);
    });

    testWidgets('handles long error messages', (WidgetTester tester) async {
      const longMessage =
          'This is a very long error message that describes in detail what went wrong with the operation';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: longMessage)),
        ),
      );

      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('message has center text alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: 'Test error')),
        ),
      );

      final text = tester.widget<Text>(find.text('Test error'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('retry button displays icon and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom.ErrorWidget(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      // Check that both icon and text are present
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('column has correct alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: custom.ErrorWidget(message: 'Error')),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });
  });
}
