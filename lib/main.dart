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
