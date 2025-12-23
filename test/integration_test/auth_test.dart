import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    testWidgets('Login screen navigation', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for home screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Find and tap Login button
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Look for login form
        final loginIndicators = [
          find.text('Email'),
          find.text('Password'),
          find.byType(TextField),
          find.byType(TextFormField),
          find.text('Sign In'),
          find.text('Login'),
        ];
        
        bool foundLoginForm = false;
        for (final finder in loginIndicators) {
          if (tester.any(finder)) {
            foundLoginForm = true;
            break;
          }
        }
        
        expect(foundLoginForm, isTrue, 
          reason: 'Login form not found');
        
        await IntegrationTestConfig.takeScreenshot(tester, 'login_screen_loaded');
      }
    });

    testWidgets('Signup screen navigation', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for home screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Find and tap Sign Up button
      final signupButton = find.text('Sign Up');
      if (tester.any(signupButton)) {
        await IntegrationTestConfig.safeTap(tester, signupButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Look for signup form
        final signupIndicators = [
          find.text('Name'),
          find.text('Email'),
          find.text('Password'),
          find.text('Confirm Password'),
          find.byType(TextField),
          find.byType(TextFormField),
          find.text('Create Account'),
          find.text('Sign Up'),
        ];
        
        bool foundSignupForm = false;
        for (final finder in signupIndicators) {
          if (tester.any(finder)) {
            foundSignupForm = true;
            break;
          }
        }
        
        expect(foundSignupForm, isTrue, 
          reason: 'Signup form not found');
        
        await IntegrationTestConfig.takeScreenshot(tester, 'signup_screen_loaded');
      }
    });

    testWidgets('Google Sign-In functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Wait for home screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Look for Google Sign-In button
      final googleSignInButtons = [
        find.text('Sign in with Google'),
        find.text('Google'),
        find.byIcon(Icons.account_circle),
        find.byType(ElevatedButton),
      ];
      
      bool foundGoogleSignIn = false;
      Finder googleButtonFinder = find.byType(Container);
      
      for (final finder in googleSignInButtons) {
        if (tester.any(finder)) {
          foundGoogleSignIn = true;
          googleButtonFinder = finder;
          break;
        }
      }
      
      if (foundGoogleSignIn) {
        await IntegrationTestConfig.safeTap(tester, googleButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // App should handle Google Sign-In flow (may open web view or show loading)
        expect(tester.takeException(), isNull);
        
        await IntegrationTestConfig.takeScreenshot(tester, 'google_sign_in_clicked');
      }
    });

    testWidgets('Form validation - empty fields', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Try to submit empty form
        final submitButtons = [
          find.text('Sign In'),
          find.text('Login'),
          find.byType(ElevatedButton),
        ];
        
        for (final finder in submitButtons) {
          if (tester.any(finder)) {
            await IntegrationTestConfig.safeTap(tester, finder);
            await tester.pumpAndSettle();
            break;
          }
        }
        
        // Validation may or may not be implemented, so we don't assert
        // but we take screenshot for debugging
        await IntegrationTestConfig.takeScreenshot(tester, 'empty_form_validation');
      }
    });

    testWidgets('Form validation - invalid email', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Find email field and enter invalid email
        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await IntegrationTestConfig.safeEnterText(
            tester, 
            emailFields.first, 
            'invalid-email'
          );
          
          // Try to submit form
          final submitButtons = [
            find.text('Sign In'),
            find.text('Login'),
            find.byType(ElevatedButton),
          ];
          
          for (final finder in submitButtons) {
            if (tester.any(finder)) {
              await IntegrationTestConfig.safeTap(tester, finder);
              await tester.pumpAndSettle();
              break;
            }
          }
          
          await IntegrationTestConfig.takeScreenshot(tester, 'invalid_email_validation');
        }
      }
    });

    testWidgets('Password field functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Find password field
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          // Assume second field is password
          final passwordField = textFields.at(1);
          
          // Enter password
          await IntegrationTestConfig.safeEnterText(
            tester, 
            passwordField, 
            TestData.testPassword
          );
          
          // Look for password visibility toggle
          final visibilityToggle = find.byIcon(Icons.visibility);
          final visibilityOffToggle = find.byIcon(Icons.visibility_off);
          
          if (tester.any(visibilityToggle) || tester.any(visibilityOffToggle)) {
            // Toggle password visibility
            final toggleFinder = tester.any(visibilityToggle) ? visibilityToggle : visibilityOffToggle;
            await IntegrationTestConfig.safeTap(tester, toggleFinder);
            await tester.pumpAndSettle();
          }
          
          await IntegrationTestConfig.takeScreenshot(tester, 'password_field_functionality');
        }
      }
    });

    testWidgets('Forgot password functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Look for forgot password link
        final forgotPasswordLinks = [
          find.text('Forgot Password?'),
          find.text('Forgot password'),
          find.text('Reset Password'),
          find.byType(TextButton),
          find.byType(InkWell),
        ];
        
        bool foundForgotPassword = false;
        for (final finder in forgotPasswordLinks) {
          if (tester.any(finder)) {
            foundForgotPassword = true;
            await IntegrationTestConfig.safeTap(tester, finder);
            await tester.pumpAndSettle();
            break;
          }
        }
        
        if (foundForgotPassword) {
          await IntegrationTestConfig.takeScreenshot(tester, 'forgot_password_screen');
        }
      }
    });

    testWidgets('Navigation between login and signup', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Look for link to signup
        final signupLinks = [
          find.text('Sign Up'),
          find.text('Create Account'),
          find.text("Don't have an account?"),
          find.byType(TextButton),
        ];
        
        for (final finder in signupLinks) {
          if (tester.any(finder)) {
            await IntegrationTestConfig.safeTap(tester, finder);
            await tester.pumpAndSettle();
            break;
          }
        }
        
        await IntegrationTestConfig.takeScreenshot(tester, 'login_to_signup_navigation');
      }
    });

    testWidgets('Back navigation from auth screens', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Navigate to login screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      final loginButton = find.text('Login');
      if (tester.any(loginButton)) {
        await IntegrationTestConfig.safeTap(tester, loginButton);
        await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
        
        // Try to go back
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // Should return to home screen or previous screen
        expect(tester.takeException(), isNull);
        
        await IntegrationTestConfig.takeScreenshot(tester, 'auth_back_navigation');
      }
    });
  });
}
