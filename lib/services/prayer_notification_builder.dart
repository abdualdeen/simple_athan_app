import '../models/app_location.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_notification.dart';
import '../models/prayer_schedule.dart';
import '../models/prayer_settings.dart';
import 'prayer_times_service.dart';

/// Builds the rolling window of prayer reminders.
///
/// Prayer times change every day, so notifications cannot simply repeat at a
/// fixed time. Instead a window of upcoming days is scheduled and refreshed
/// whenever the app opens, the location changes, or the settings change.
abstract final class PrayerNotificationBuilder {
  /// iOS keeps at most 64 pending notifications; 7 days x 5 prayers = 35.
  static const int daysAhead = 7;

  static List<PrayerNotification> build({
    required DateTime now,
    required AppLocation location,
    required PrayerSettings settings,
    required NotificationSettings notificationSettings,
    PrayerTimesService prayerTimesService = const PrayerTimesService(),
  }) {
    if (!notificationSettings.enabled) return const <PrayerNotification>[];

    final List<PrayerNotification> notifications = <PrayerNotification>[];
    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final DateTime date = DateTime(now.year, now.month, now.day + dayOffset);
      final PrayerSchedule schedule = prayerTimesService.scheduleFor(
        date: date,
        location: location,
        settings: settings,
      );

      for (final PrayerTime prayer in schedule.prayers) {
        if (!prayer.isPrayer) continue;
        if (!notificationSettings.isEnabledFor(prayer.id)) continue;
        if (!prayer.time.isAfter(now)) continue;

        notifications.add(
          PrayerNotification(
            id: dayOffset * 10 + prayer.id.index,
            prayer: prayer.id,
            time: prayer.time,
            title: '${prayer.label} prayer',
            body: 'It is time for ${prayer.label} in ${location.name}.',
          ),
        );
      }
    }
    return notifications;
  }
}
