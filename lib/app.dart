// Simply Athan - prayer times and Qibla app.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
    // The prayer controller is listened to as well so the theme flips live
    // when the auto night theme crosses sunset or sunrise.
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[themeController, controller]),
      builder: (BuildContext context, Widget? _) {
        AppThemeChoice choice = themeController.choice;
        if (themeController.autoTheme && controller.isNight) {
          choice = choice.counterpart;
        }
        return MaterialApp(
          title: 'Athan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forChoice(choice),
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
