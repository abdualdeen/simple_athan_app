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

import 'prayer.dart';

/// A single prayer reminder ready to be handed to the notification plugin.
@immutable
class PrayerNotification {
  const PrayerNotification({
    required this.id,
    required this.prayer,
    required this.time,
    required this.title,
    required this.body,
  });

  final int id;
  final PrayerId prayer;
  final DateTime time;
  final String title;
  final String body;
}
