import 'package:flutter/material.dart';

import 'controllers/prayer_times_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

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
          home: HomeScreen(
            controller: controller,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
