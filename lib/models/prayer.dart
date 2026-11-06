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

import 'package:flutter/material.dart';

enum PrayerId {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  static PrayerId? fromName(String? name) {
    for (final PrayerId id in values) {
      if (id.name == name) return id;
    }
    return null;
  }
}

extension PrayerIdDetails on PrayerId {
  String get label => switch (this) {
    PrayerId.fajr => 'Fajr',
    PrayerId.sunrise => 'Sunrise',
    PrayerId.dhuhr => 'Dhuhr',
    PrayerId.asr => 'Asr',
    PrayerId.maghrib => 'Maghrib',
    PrayerId.isha => 'Isha',
  };

  String get arabicLabel => switch (this) {
    PrayerId.fajr => 'الفجر',
    PrayerId.sunrise => 'الشروق',
    PrayerId.dhuhr => 'الظهر',
    PrayerId.asr => 'العصر',
    PrayerId.maghrib => 'المغرب',
    PrayerId.isha => 'العشاء',
  };

  IconData get icon => switch (this) {
    PrayerId.fajr => Icons.nightlight_round,
    PrayerId.sunrise => Icons.wb_twilight,
    PrayerId.dhuhr => Icons.wb_sunny_outlined,
    PrayerId.asr => Icons.light_mode_outlined,
    PrayerId.maghrib => Icons.nights_stay_outlined,
    PrayerId.isha => Icons.bedtime_outlined,
  };

  /// Sunrise is a time marker, not one of the five obligatory prayers.
  bool get isPrayer => this != PrayerId.sunrise;
}

@immutable
class PrayerTime {
  const PrayerTime({required this.id, required this.time});

  final PrayerId id;
  final DateTime time;

  String get label => id.label;
  String get arabicLabel => id.arabicLabel;
  IconData get icon => id.icon;
  bool get isPrayer => id.isPrayer;
}
