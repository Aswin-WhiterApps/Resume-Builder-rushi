import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple mock widget for golden testing
class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.blueGrey,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to Resume Builder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Create professional resumes with ease',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Home Screen Golden Tests', () {
    // ✅ STEP 7: Multiple Themes (Light / Dark)
    testWidgets('Home Screen - Light Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_light.png'),
      );
    });

    testWidgets('Home Screen - Dark Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_dark.png'),
      );
    });

    // ✅ STEP 8: Multiple Locales (Languages) - Simplified
    testWidgets('Home Screen - English Locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: const MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_english.png'),
      );
    });

    testWidgets('Home Screen - Alternative Locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ta'),
          home: const MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_tamil.png'),
      );
    });

    // ✅ STEP 9: Device Sizes (Mobile / Tablet)
    testWidgets('Home Screen - Mobile Size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812)); // iPhone X
      
      await tester.pumpWidget(
        const MaterialApp(
          home: MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_mobile.png'),
      );
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Home Screen - Tablet Size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1366)); // iPad
      
      await tester.pumpWidget(
        const MaterialApp(
          home: MockHomeScreen(),
        ),
      );
      
      await expectLater(
        find.byType(MockHomeScreen),
        matchesGoldenFile('goldens/home_screen_tablet.png'),
      );
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
