import '../models/athan_sound.dart';
import '../models/prayer_notification.dart';

/// Platform notification scheduling used by the app.
abstract interface class NotificationService {
  Future<void> initialize();

  /// Requests notification permission and returns whether it was granted.
  Future<bool> requestPermission();

  /// Whether the platform allows exact (alarm-style) scheduling.
  Future<bool> canScheduleExactNotifications();

  /// Opens the system screen that grants exact alarm scheduling.
  Future<bool> requestExactAlarmsPermission();

  /// Replaces all pending prayer reminders with [notifications], played
  /// with [sound].
  Future<void> schedulePrayerNotifications({
    required List<PrayerNotification> notifications,
    AthanSound sound = AthanSound.system,
  });

  Future<void> cancelAll();

  Future<void> showTestNotification({AthanSound sound = AthanSound.system});
}
