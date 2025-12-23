import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Resume Builder Tests', () {
    testWidgets('Test setup works correctly', (WidgetTester tester) async {
      // Create a simple test widget to verify setup
      await pumpApp(tester, Container());
      
      // Verify the MaterialApp was created successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Should display basic text widget', (WidgetTester tester) async {
      await pumpApp(tester, Text('Test Widget'));
      
      expect(find.text('Test Widget'), findsOneWidget);
    });
  });
}