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
import 'package:flutter/services.dart';

import '../models/prayer.dart';
import '../models/prayer_schedule.dart';

/// Pushes prayer times to the Android home screen widget.
///
/// Days are sent in order starting with today; the native side stores them
/// under local epoch-day keys so it can pick the right day after midnight
/// without the app running.
class HomeWidgetService {
  const HomeWidgetService();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel('athan_app/home_widget');

  /// Sends [days] of prayer times (index 0 = today) for [locationName].
  Future<void> updatePrayerTimes({
    required String locationName,
    required List<PrayerSchedule> days,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final List<List<int>> payload = <List<int>>[
      for (final PrayerSchedule day in days)
        <int>[
          for (final PrayerTime prayer in day.prayers)
            if (prayer.isPrayer) prayer.time.millisecondsSinceEpoch,
        ],
    ];

    await channel.invokeMethod<void>('updatePrayerTimes', <String, Object>{
      'locationName': locationName,
      'days': payload,
    });
  }
}
