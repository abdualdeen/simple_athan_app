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

import 'prayer.dart';

/// All prayer times for a single day.
class PrayerSchedule {
  const PrayerSchedule({required this.date, required this.prayers});

  final DateTime date;
  final List<PrayerTime> prayers;
}

/// A day's schedule together with the prayers surrounding "now".
class PrayerDay {
  const PrayerDay({
    required this.schedule,
    required this.next,
    required this.previous,
  });

  final PrayerSchedule schedule;
  final PrayerTime next;
  final PrayerTime previous;
}
