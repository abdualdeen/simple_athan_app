import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/prayer_times_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/local_notification_service.dart';
import 'services/location_service.dart';
import 'services/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SettingsStore settingsStore = SharedPreferencesSettingsStore();
  final PrayerTimesController controller = PrayerTimesController(
    locationService: const DeviceLocationService(),
    settingsStore: settingsStore,
    notificationService: LocalNotificationService(),
  );
  final ThemeController themeController = ThemeController(
    settingsStore: settingsStore,
  );
  // Apply the saved theme on the first frame to avoid a theme flash.
  await themeController.initialize();
  unawaited(controller.initialize());

  runApp(AthanApp(controller: controller, themeController: themeController));
}
