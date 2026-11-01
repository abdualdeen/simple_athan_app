import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/notification_settings.dart';
import 'package:athan_app/models/prayer.dart';
import 'package:athan_app/models/prayer_notification.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/services/prayer_notification_builder.dart';
import 'package:athan_app/services/prayer_times_service.dart';

/// A location aligned with the machine's timezone so the test does not depend
/// on where it runs.
AppLocation _localLocation() {
  final double longitude = DateTime.now().timeZoneOffset.inMinutes / 4.0;
  return AppLocation(name: 'Local', latitude: 0, longitude: longitude);
}

void main() {
  const PrayerTimesService service = PrayerTimesService();

  test('builds a week of reminders for the five prayers', () {
    final AppLocation location = _localLocation();
    final DateTime now = DateTime(2026, 11, 1);

    final List<PrayerNotification> notifications =
        PrayerNotificationBuilder.build(
          now: now,
          location: location,
          settings: const PrayerSettings(),
          notificationSettings: const NotificationSettings(),
          prayerTimesService: service,
        );

    expect(notifications.length, 35);
    expect(
      notifications.map((PrayerNotification n) => n.id).toSet().length,
      35,
    );
    expect(
      notifications.every((PrayerNotification n) => n.time.isAfter(now)),
      isTrue,
    );
    expect(
      notifications.every((PrayerNotification n) => n.prayer.isPrayer),
      isTrue,
    );
    for (int i = 1; i < notifications.length; i++) {
      expect(notifications[i].time.isAfter(notifications[i - 1].time), isTrue);
    }
  });

  test('skips muted prayers and times that have already passed', () {
    final AppLocation location = _localLocation();
    final schedule = service.scheduleFor(
      date: DateTime(2026, 11, 1),
      location: location,
      settings: const PrayerSettings(),
    );
    final DateTime now = schedule.prayers.first.time.add(
      const Duration(minutes: 1),
    );

    final List<PrayerNotification> notifications =
        PrayerNotificationBuilder.build(
          now: now,
          location: location,
          settings: const PrayerSettings(),
          notificationSettings: const NotificationSettings(
            muted: <PrayerId>{PrayerId.fajr, PrayerId.isha},
          ),
          prayerTimesService: service,
        );

    expect(
      notifications.any((PrayerNotification n) => n.prayer == PrayerId.fajr),
      isFalse,
    );
    expect(
      notifications.any((PrayerNotification n) => n.prayer == PrayerId.isha),
      isFalse,
    );
    // Three remaining prayers today plus three per day for the next six days
    // (Fajr and Isha are muted).
    expect(notifications.length, 21);
  });

  test('returns nothing when notifications are disabled', () {
    final List<PrayerNotification> notifications =
        PrayerNotificationBuilder.build(
          now: DateTime(2026, 11, 1),
          location: _localLocation(),
          settings: const PrayerSettings(),
          notificationSettings: const NotificationSettings(enabled: false),
          prayerTimesService: service,
        );

    expect(notifications, isEmpty);
  });
}
