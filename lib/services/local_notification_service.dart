import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_notification.dart';
import 'notification_service.dart';

/// Schedules prayer reminders with the platform notification services.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'athan_prayers';
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
        notificationDetails: _details,
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
  Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      id: 9999,
      title: 'Athan test notification',
      body: 'Prayer reminders are working.',
      notificationDetails: _details,
    );
  }

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      icon: 'ic_stat_athan',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
