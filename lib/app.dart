import 'package:flutter/material.dart';

import 'controllers/prayer_times_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/startup_view.dart';

class AthanApp extends StatelessWidget {
  const AthanApp({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp(
          title: 'Athan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forChoice(themeController.choice),
          home: _EntryScreen(
            controller: controller,
            themeController: themeController,
          ),
        );
      },
    );
  }
}

/// Picks what to show: the loader while state loads, the first-launch intro,
/// or the home screen.
class _EntryScreen extends StatelessWidget {
  const _EntryScreen({required this.controller, required this.themeController});

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        if (controller.isInitializing) return const StartupView();
        if (!controller.isOnboardingComplete) {
          return OnboardingScreen(
            controller: controller,
            themeController: themeController,
          );
        }
        return HomeScreen(
          controller: controller,
          themeController: themeController,
        );
      },
    );
  }
}
