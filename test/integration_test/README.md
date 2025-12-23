# Integration Tests

This directory contains integration tests for the Resume Builder Flutter application.

## Setup

Integration tests are already configured in `pubspec.yaml` with the `integration_test` dependency.

## Running Tests

### Run all integration tests:
```bash
flutter test integration_test/
```

### Run specific test file:
```bash
flutter test integration_test/app_test.dart
flutter test integration_test/resume_builder_test.dart
flutter test integration_test/auth_test.dart
```

### Run with device:
```bash
flutter test integration_test/ --device=<device_id>
```

## Test Files

- **app_test.dart** - Basic app launch, splash screen, navigation, and system behavior tests
- **resume_builder_test.dart** - Complete resume building flow, tab navigation, form functionality
- **auth_test.dart** - Login/signup screens, form validation, Google Sign-In, password reset
- **test_config.dart** - Shared utilities, helpers, and test configuration

## Test Configuration

The `test_config.dart` file provides:

- `IntegrationTestConfig` class with common testing utilities
- `AppFinders` class with predefined widget finders
- `TestData` class with test data constants

## Features Tested

### App Tests
- App launches successfully
- Splash screen display
- Home screen navigation
- Orientation changes
- Back navigation
- Lifecycle management
- Memory pressure handling

### Resume Builder Tests
- Complete resume building workflow
- Contact tab functionality
- Work experience tab
- Education tab
- Summary tab
- Template selection
- Download options
- Tab navigation
- Save functionality

### Authentication Tests
- Login screen navigation
- Signup screen navigation
- Google Sign-In
- Form validation
- Password field functionality
- Forgot password flow
- Navigation between auth screens
- Back navigation

## Screenshots

Tests automatically take screenshots at key points for debugging:
- Screenshots are saved in `build/integration_test/`
- Each screenshot is named descriptively (e.g., `app_launch`, `resume_builder_loaded`)

## Best Practices

1. **Use the provided utilities** - Leverage `IntegrationTestConfig` methods for consistent behavior
2. **Wait for widgets** - Always use `safeTap` and `waitForWidget` methods
3. **Handle timeouts** - Use appropriate timeout values for different operations
4. **Take screenshots** - Screenshots are automatically captured for debugging
5. **Test real user flows** - Tests simulate actual user interactions

## Troubleshooting

### Common Issues

1. **Tests fail to find widgets**
   - Check if the app has fully loaded using `pumpAndSettle()`
   - Verify widget keys and text match what's expected
   - Use screenshots to debug the current app state

2. **Timeout errors**
   - Increase timeout values in `IntegrationTestConfig`
   - Check if the app is stuck on loading screens
   - Verify network connectivity for auth tests

3. **Firebase/Google Sign-In issues**
   - Ensure test environment has proper configuration
   - Mock Firebase services for consistent test results
   - Check if test device has Google Play Services

## Adding New Tests

1. Create a new test file in the `integration_test/` directory
2. Import `test_config.dart` for utilities
3. Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` at the start
4. Follow the existing test patterns and naming conventions
5. Add appropriate screenshots for debugging

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Integration Tests
  run: flutter test integration_test/
```

## Notes

- Tests require a physical device or emulator to run
- Some tests may require internet connection for auth features
- Tests are designed to be independent and can run in any order
- Mock data is used where appropriate to ensure consistent test results
