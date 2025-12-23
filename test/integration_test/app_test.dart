import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Initialize integration test
      await IntegrationTestConfig.initApp();
      
      // Wait for app to fully load
      await tester.pumpAndSettle(IntegrationTestConfig.longTimeout);
      
      // Verify app is running (no crashes)
      expect(tester.takeException(), isNull);
      
      // Take screenshot for debugging
      await IntegrationTestConfig.takeScreenshot(tester, 'app_launch');
    });

    testWidgets('App shows splash screen initially', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for splash screen to appear
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Look for splash screen indicators (logo, app name, etc.)
      final splashIndicators = [
        find.text('Resume Builder'),
        find.byType(CircularProgressIndicator),
        find.byType(Image),
      ];
      
      // At least one splash indicator should be present
      bool foundSplashIndicator = false;
      for (final finder in splashIndicators) {
        if (tester.any(finder)) {
          foundSplashIndicator = true;
          break;
        }
      }
      
      expect(foundSplashIndicator, isTrue, 
        reason: 'No splash screen indicators found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'splash_screen');
    });

    testWidgets('App navigates to home screen after splash', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for splash screen to complete and home screen to appear
      await tester.pumpAndSettle(IntegrationTestConfig.longTimeout);
      
      // Look for home screen indicators
      final homeIndicators = [
        find.text('Create Resume'),
        find.text('Login'),
        find.text('Sign Up'),
        find.byType(ElevatedButton),
        find.byType(Card),
      ];
      
      // At least one home screen indicator should be present
      bool foundHomeIndicator = false;
      for (final finder in homeIndicators) {
        if (tester.any(finder)) {
          foundHomeIndicator = true;
          break;
        }
      }
      
      expect(foundHomeIndicator, isTrue, 
        reason: 'No home screen indicators found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'home_screen');
    });

    testWidgets('App handles orientation changes', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for app to load
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      
      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(640, 360));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      
      // Reset to portrait
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      
      await IntegrationTestConfig.takeScreenshot(tester, 'orientation_test');
    });

    testWidgets('App handles back navigation gracefully', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for app to load
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Try to go back (should not crash)
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // App should still be running
      expect(tester.takeException(), isNull);
      
      await IntegrationTestConfig.takeScreenshot(tester, 'back_navigation_test');
    });

    testWidgets('App maintains state during configuration changes', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for initial load
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Simulate app going to background and coming back
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.paused'),
        (data) {},
      );
      
      await tester.pumpAndSettle();
      
      // App comes back to foreground
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );
      
      await tester.pumpAndSettle();
      
      // App should still be responsive
      expect(tester.takeException(), isNull);
      
      await IntegrationTestConfig.takeScreenshot(tester, 'lifecycle_test');
    });

    testWidgets('App handles memory pressure', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for app to load
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Simulate memory pressure warning
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/system',
        const StringCodec().encodeMessage('memoryPressure'),
        (data) {},
      );
      
      await tester.pumpAndSettle();
      
      // App should still be running
      expect(tester.takeException(), isNull);
      
      await IntegrationTestConfig.takeScreenshot(tester, 'memory_pressure_test');
    });
  });
}
