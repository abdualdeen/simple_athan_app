import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/prayer_times_controller.dart';
import 'services/local_notification_service.dart';
import 'services/location_service.dart';
import 'services/settings_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final PrayerTimesController controller = PrayerTimesController(
    locationService: const DeviceLocationService(),
    settingsStore: SharedPreferencesSettingsStore(),
    notificationService: LocalNotificationService(),
  );
  unawaited(controller.initialize());

  runApp(AthanApp(controller: controller));
}
