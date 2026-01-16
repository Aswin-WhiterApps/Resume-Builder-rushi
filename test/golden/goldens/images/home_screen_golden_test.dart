import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:resume_builder/Presentation/homescreen/homescreen.dart';

void main() {
  testGoldens('Home Screen - default theme', (tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario(
        'Default',
        const HomeScreenView(),
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(375, 812), // iPhone X size
    );

    await screenMatchesGolden(tester, 'home_screen_default');
  });
}
