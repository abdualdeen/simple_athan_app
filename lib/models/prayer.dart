import 'package:flutter/material.dart';

enum PrayerId { fajr, sunrise, dhuhr, asr, maghrib, isha }

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
