import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/presentation/widgets/common/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('displays CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (WidgetTester tester) async {
      const testMessage = 'Loading your apps...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: testMessage)),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not display message when null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      // Should only have the progress indicator, not a Text widget for message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('is centered on screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('displays multiple messages correctly', (
      WidgetTester tester,
    ) async {
      const message1 = 'Loading apps...';
      const message2 = 'Please wait...';

      // Test first message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: message1)),
        ),
      );

      expect(find.text(message1), findsOneWidget);

      // Test second message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: message2)),
        ),
      );

      expect(find.text(message2), findsOneWidget);
      expect(find.text(message1), findsNothing);
    });

    testWidgets('column has correct alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: 'Test')),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('text has center alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: 'Test message')),
        ),
      );

      final text = tester.widget<Text>(find.text('Test message'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('handles long messages', (WidgetTester tester) async {
      const longMessage =
          'This is a very long loading message that might wrap to multiple lines';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: longMessage)),
        ),
      );

      expect(find.text(longMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
