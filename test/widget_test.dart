import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('Test setup works correctly', (WidgetTester tester) async {
      await pumpApp(tester, Container());
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}