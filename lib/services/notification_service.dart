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
