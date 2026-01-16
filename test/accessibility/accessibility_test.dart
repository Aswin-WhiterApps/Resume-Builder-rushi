import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_builder/Presentation/splash/splash.dart';
import 'package:resume_builder/Presentation/login/login.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_state.dart';
import 'package:resume_builder/blocs/auth/auth_event.dart';
import 'package:resume_builder/blocs/work/work_state.dart';
import 'package:resume_builder/blocs/work/work_event.dart';
import 'package:bloc_test/bloc_test.dart';

// Mock Classes
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockWorkBloc extends MockBloc<WorkEvent, WorkState> implements WorkBloc {}

// Helper to create testable widget
Widget createTestableWidget(
    {required Widget child, AuthBloc? authBloc, WorkBloc? workBloc}) {
  return MultiBlocProvider(
    providers: [
      if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
      if (workBloc != null) BlocProvider<WorkBloc>.value(value: workBloc),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Accessibility Tests', () {
    testWidgets('Splash Screen has correct semantics',
        (WidgetTester tester) async {
      // Setup Mock AuthBloc to avoid side effects
      final mockAuthBloc = MockAuthBloc();
      whenListen(
        mockAuthBloc,
        Stream.value(AuthInitial()),
        initialState: AuthInitial(),
      );

      // Define a SemanticsHandle to enable semantics for testing
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(createTestableWidget(
          child: const SplashView(), authBloc: mockAuthBloc));

      // Wait for animations
      await tester.pump(const Duration(seconds: 3));

      // Check for Semantics
      expect(find.bySemanticsLabel('Resume Builder Application Logo'),
          findsOneWidget);
      expect(find.bySemanticsLabel('Whiterapps Logo'), findsOneWidget);
      // AppStrings.splashStatement might need to be checked if it matches exact string

      // Clean up
      handle.dispose();
    });

    testWidgets('Login Screen has accessible buttons and fields',
        (WidgetTester tester) async {
      final mockAuthBloc = MockAuthBloc();
      whenListen(
        mockAuthBloc,
        Stream.value(AuthInitial()),
        initialState: AuthInitial(),
      );

      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(createTestableWidget(
          child: const LoginView(), authBloc: mockAuthBloc));

      // Verify Sign In Button Label
      expect(find.bySemanticsLabel('Sign In Button'), findsOneWidget);

      // Verify Google Sign In Tooltip/Label
      expect(find.byTooltip('Sign in with Google'), findsOneWidget);

      handle.dispose();
    });

    // Note: Testing HomeScreen and ResumeBuilder might require more complex mocking
    // of MySingleton and other dependencies which is out of scope for basic check,
    // but we can test individual widgets or parts if properly isolated.
    // For now, Splash and Login provide good coverage of the changes we made.
  });
}
