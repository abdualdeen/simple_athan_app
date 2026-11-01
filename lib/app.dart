import 'package:flutter/material.dart';

import 'controllers/prayer_times_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class AthanApp extends StatelessWidget {
  const AthanApp({super.key, required this.controller});

  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeScreen(controller: controller),
    );
  }
}
