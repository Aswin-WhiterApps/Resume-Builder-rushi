import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resume_builder/app/app.dart';
import 'package:resume_builder/blocs/additional_tab/additional_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/blocs/contact_tab/contact_bloc.dart';
import 'package:resume_builder/blocs/summary/summary_bloc.dart';
import 'package:resume_builder/firestore/user_firestore.dart';

/// Integration test configuration and utilities
class IntegrationTestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(minutes: 2);
  
  /// Initialize the app for integration testing
  static Future<void> initApp() async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    // Don't call app.main() here as it can cause zone mismatches
    await Future.delayed(const Duration(seconds: 1)); // Wait for any async setup
  }
  
  /// Initialize the app widget for testing
  static Widget createTestApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(FireUser()),
        ),
        BlocProvider<ContactBloc>(
          create: (_) => ContactBloc(fireUser: FireUser()),
        ),
        BlocProvider<AdditionalBloc>(
          create: (_) => AdditionalBloc(),
        ),
        BlocProvider<WorkBloc>(
          create: (_) => WorkBloc(fireUser: FireUser()),
        ),
        BlocProvider(
          create: (_) => SummaryBloc(fireUser: FireUser()),
        ),
      ],
      child: MyApp(),
    );
  }
  
  /// Wait for a widget to appear with timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    await tester.pumpAndSettle(timeout);
    expect(finder, findsOneWidget);
  }
  
  /// Wait for multiple widgets to appear
  static Future<void> waitForWidgets(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = defaultTimeout,
  }) async {
    await tester.pumpAndSettle(timeout);
    for (final finder in finders) {
      expect(finder, findsOneWidget);
    }
  }
  
  /// Safe tap with waiting
  static Future<void> safeTap(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForWidget(tester, finder, timeout: timeout);
    await tester.tap(finder);
    await tester.pumpAndSettle(timeout);
  }
  
  /// Safe text entry
  static Future<void> safeEnterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    bool clearFirst = true,
    Duration timeout = defaultTimeout,
  }) async {
    await waitForWidget(tester, finder, timeout: timeout);
    if (clearFirst) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/textinput',
        null,
        (data) {},
      );
    }
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(timeout);
  }
  
  /// Scroll until widget is found
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder scrollable,
    Finder target, {
    double delta = 100.0,
    Duration timeout = defaultTimeout,
  }) async {
    await tester.pumpAndSettle();
    
    bool found = false;
    int attempts = 0;
    const maxAttempts = 10;
    
    while (!found && attempts < maxAttempts) {
      found = tester.any(target);
      if (!found) {
        await tester.drag(scrollable, Offset(0, -delta));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        attempts++;
      }
    }
    
    if (!found) {
      throw TestFailure('Widget not found after $maxAttempts scroll attempts');
    }
  }
  
  /// Take screenshot for debugging
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    await binding.takeScreenshot(name);
  }
  
  /// Get the binding instance
  static IntegrationTestWidgetsFlutterBinding get binding {
    return IntegrationTestWidgetsFlutterBinding.instance;
  }
}

/// Common finders used across integration tests
class AppFinders {
  static final splashScreen = find.byKey(const Key('splash_screen'));
  static final homeScreen = find.byKey(const Key('home_screen'));
  static final loginScreen = find.byKey(const Key('login_screen'));
  static final resumeBuilder = find.byKey(const Key('resume_builder'));
  static final contactsTab = find.byKey(const Key('contacts_tab'));
  static final workTab = find.byKey(const Key('work_tab'));
  static final educationTab = find.byKey(const Key('education_tab'));
  static final summaryTab = find.byKey(const Key('summary_tab'));
  static final templatesTab = find.byKey(const Key('templates_tab'));
  static final downloadTab = find.byKey(const Key('download_tab'));
  
  // Button finders
  static final continueButton = find.text('Continue');
  static final saveButton = find.text('Save');
  static final nextButton = find.text('Next');
  static final previousButton = find.text('Previous');
  static final createResumeButton = find.text('Create Resume');
  static final loginButton = find.text('Login');
  static final signupButton = find.text('Sign Up');
  
  // Input field finders
  static final emailField = find.byKey(const Key('email_field'));
  static final passwordField = find.byKey(const Key('password_field'));
  static final nameField = find.byKey(const Key('name_field'));
  static final phoneField = find.byKey(const Key('phone_field'));
  
  // Navigation finders
  static final bottomNavigationBar = find.byType(BottomNavigationBar);
  static final appBar = find.byType(AppBar);
  static final floatingActionButton = find.byType(FloatingActionButton);
}

/// Test data constants
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123456!';
  static const String testName = 'Test User';
  static const String testPhone = '+1234567890';
  static const String testJobTitle = 'Software Engineer';
  static const String testCompany = 'Test Company';
  static const String testSummary = 'Experienced software engineer with expertise in Flutter development.';
}
