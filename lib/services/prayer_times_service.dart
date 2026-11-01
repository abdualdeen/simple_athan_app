import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../models/app_location.dart';
import '../models/prayer.dart';
import '../models/prayer_schedule.dart';
import '../models/prayer_settings.dart';

/// Calculates prayer times with the Adhan astronomical library.
///
/// Adhan returns UTC times, so every value is converted to the device's local
/// timezone before it reaches the UI.
class PrayerTimesService {
  const PrayerTimesService();

  PrayerSchedule scheduleFor({
    required DateTime date,
    required AppLocation location,
    required PrayerSettings settings,
  }) {
    final adhan.Coordinates coordinates = adhan.Coordinates(
      location.latitude,
      location.longitude,
    );
    final adhan.CalculationParameters parameters = settings.method.parameters()
      ..madhab = settings.madhab == AsrMadhab.hanafi
          ? adhan.Madhab.hanafi
          : adhan.Madhab.shafi
      ..highLatitudeRule = adhan.HighLatitudeRule.recommended(coordinates);

    // Adhan expects the calendar date as a UTC instant; passing a local
    // midnight shifts the solar calculations by the device's UTC offset.
    final adhan.PrayerTimes times = adhan.PrayerTimes(
      date: DateTime.utc(date.year, date.month, date.day),
      coordinates: coordinates,
      calculationParameters: parameters,
    );

    return PrayerSchedule(
      date: DateTime(date.year, date.month, date.day),
      prayers: <PrayerTime>[
        PrayerTime(id: PrayerId.fajr, time: times.fajr.toLocal()),
        PrayerTime(id: PrayerId.sunrise, time: times.sunrise.toLocal()),
        PrayerTime(id: PrayerId.dhuhr, time: times.dhuhr.toLocal()),
        PrayerTime(id: PrayerId.asr, time: times.asr.toLocal()),
        PrayerTime(id: PrayerId.maghrib, time: times.maghrib.toLocal()),
        PrayerTime(id: PrayerId.isha, time: times.isha.toLocal()),
      ],
    );
  }

  /// The schedule for [now]'s date plus the next and previous obligatory
  /// prayers. Rolls over to tomorrow's Fajr after Isha and to yesterday's Isha
  /// before Fajr.
  PrayerDay dayFor({
    required DateTime now,
    required AppLocation location,
    required PrayerSettings settings,
  }) {
    final PrayerSchedule today = scheduleFor(
      date: now,
      location: location,
      settings: settings,
    );

    PrayerTime? next;
    PrayerTime? previous;
    for (final PrayerTime prayer in today.prayers) {
      if (!prayer.isPrayer) continue;
      if (prayer.time.isAfter(now)) {
        next ??= prayer;
      } else {
        previous = prayer;
      }
    }

    next ??= scheduleFor(
      date: now.add(const Duration(days: 1)),
      location: location,
      settings: settings,
    ).prayers.firstWhere((PrayerTime prayer) => prayer.isPrayer);

    previous ??= scheduleFor(
      date: now.subtract(const Duration(days: 1)),
      location: location,
      settings: settings,
    ).prayers.lastWhere((PrayerTime prayer) => prayer.isPrayer);

    return PrayerDay(schedule: today, next: next, previous: previous);
  }
}
