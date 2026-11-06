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

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/athan_sound.dart';
import '../models/prayer_notification.dart';
import 'notification_service.dart';

/// Schedules prayer reminders with the platform notification services.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelIdPrefix = 'athan_prayers';
  static const String _channelName = 'Prayer times';
  static const String _channelDescription =
      'Adhan reminders for the five daily prayers';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _exactAlarmsAllowed = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      // Scheduling still works with UTC; only the wall-clock display differs.
      debugPrint('Could not resolve the device timezone: $error');
    }

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      'ic_stat_athan',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final bool? granted = await android?.requestNotificationsPermission();
      _exactAlarmsAllowed =
          await android?.canScheduleExactNotifications() ?? false;
      return granted ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final MacOSFlutterLocalNotificationsPlugin? macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      return await macos?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return true;
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? false;
    return _exactAlarmsAllowed;
  }

  @override
  Future<bool> requestExactAlarmsPermission() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool? granted = await android?.requestExactAlarmsPermission();
    _exactAlarmsAllowed =
        granted ?? await android?.canScheduleExactNotifications() ?? false;
    return _exactAlarmsAllowed;
  }

  @override
  Future<void> schedulePrayerNotifications({
    required List<PrayerNotification> notifications,
    AthanSound sound = AthanSound.system,
  }) async {
    await initialize();
    await _plugin.cancelAllPendingNotifications();
    if (notifications.isEmpty) return;

    final AndroidScheduleMode scheduleMode = _exactAlarmsAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final PrayerNotification notification in notifications) {
      await _plugin.zonedSchedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: tz.TZDateTime.from(notification.time, tz.local),
        notificationDetails: _detailsFor(sound),
        androidScheduleMode: scheduleMode,
        payload: notification.prayer.name,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAllPendingNotifications();
  }

  @override
  Future<void> showTestNotification({
    AthanSound sound = AthanSound.system,
  }) async {
    await initialize();
    await _plugin.show(
      id: 9999,
      title: 'Athan test notification',
      body: 'Prayer reminders are working.',
      notificationDetails: _detailsFor(sound),
    );
  }

  /// Builds the details for [sound].
  ///
  /// Android locks the sound of a notification channel once created, so every
  /// sound gets its own channel id. Custom sounds are bundled as raw
  /// resources on Android and as bundle files on iOS/macOS.
  static NotificationDetails _detailsFor(AthanSound sound) {
    final String channelId = '${_channelIdPrefix}_${sound.name}';

    final AndroidNotificationDetails android = AndroidNotificationDetails(
      channelId,
      _channelName,
      channelDescription: _channelDescription,
      icon: 'ic_stat_athan',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      sound: sound == AthanSound.system
          ? null
          : RawResourceAndroidNotificationSound(sound.androidResource),
    );

    final String? darwinSound = sound == AthanSound.system
        ? null
        : sound.darwinFile;

    return NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: darwinSound,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: darwinSound,
      ),
    );
  }
}
