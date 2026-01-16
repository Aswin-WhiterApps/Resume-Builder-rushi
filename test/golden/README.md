# Golden Tests Implementation

This directory contains golden tests for the Resume Builder application's home screen.

## Implemented Tests

### ✅ STEP 7: Multiple Themes (Light / Dark)
- **Test**: `Home Screen - Light Theme` - Tests the home screen with light theme
- **Test**: `Home Screen - Dark Theme` - Tests the home screen with dark theme
- **Golden Files**: 
  - `goldens/home_screen_light.png`
  - `goldens/home_screen_dark.png`

### ✅ STEP 8: Multiple Locales (Languages)
- **Test**: `Home Screen - English Locale` - Tests with English locale
- **Test**: `Home Screen - Alternative Locale` - Tests with Tamil locale
- **Golden Files**:
  - `goldens/home_screen_english.png`
  - `goldens/home_screen_tamil.png`

### ✅ STEP 9: Device Sizes (Mobile / Tablet)
- **Test**: `Home Screen - Mobile Size` - Tests on mobile device (375x812 - iPhone X)
- **Test**: `Home Screen - Tablet Size` - Tests on tablet device (1024x1366 - iPad)
- **Golden Files**:
  - `goldens/home_screen_mobile.png`
  - `goldens/home_screen_tablet.png`

## Running the Tests

To run the golden tests:

```bash
# Run tests and update golden files
flutter test test/golden/home_screen_golden_test.dart --update-goldens

# Run tests without updating (for regression testing)
flutter test test/golden/home_screen_golden_test.dart
```

## Test Structure

The tests use a `MockHomeScreen` widget that simulates the home screen UI without complex dependencies like Firebase, authentication, or network services. This approach ensures:

1. **Reliability**: Tests don't fail due to external dependencies
2. **Speed**: Tests run quickly without network calls
3. **Consistency**: Same UI structure across different test scenarios

## Key Features Tested

- **Theme Adaptation**: Verifies UI adapts correctly to light and dark themes
- **Locale Support**: Ensures layout works with different locales
- **Responsive Design**: Validates UI on different screen sizes
- **Visual Consistency**: Golden files provide visual regression testing

## Golden Files

Golden files are stored in `test/golden/goldens/` and serve as the baseline for visual comparisons. When the UI changes intentionally, update the golden files using the `--update-goldens` flag.
