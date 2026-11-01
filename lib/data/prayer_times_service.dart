import '../models/prayer.dart';

/// Placeholder prayer-time source.
///
/// Times are fixed for now so the home screen can be built and reviewed before
/// the real astronomical calculation (location + calculation method) lands.
/// Swapping this out for a location-aware service should not require any UI
/// changes.
abstract final class PrayerTimesService {
  static const String locationName = 'London, United Kingdom';

  static PrayerSchedule forDate(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);

    DateTime at(int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);

    return PrayerSchedule(
      date: day,
      prayers: <PrayerTime>[
        PrayerTime(id: PrayerId.fajr, time: at(5, 42)),
        PrayerTime(id: PrayerId.sunrise, time: at(7, 12)),
        PrayerTime(id: PrayerId.dhuhr, time: at(11, 58)),
        PrayerTime(id: PrayerId.asr, time: at(14, 41)),
        PrayerTime(id: PrayerId.maghrib, time: at(16, 44)),
        PrayerTime(id: PrayerId.isha, time: at(18, 14)),
      ],
    );
  }

  /// The next obligatory prayer after [now], rolling over to tomorrow's Fajr
  /// once Isha has passed.
  static PrayerTime nextPrayer(DateTime now) {
    for (final PrayerTime prayer in forDate(now).prayers) {
      if (prayer.isPrayer && prayer.time.isAfter(now)) return prayer;
    }
    return forDate(now.add(const Duration(days: 1))).prayers
        .firstWhere((PrayerTime prayer) => prayer.isPrayer);
  }

  /// The most recent obligatory prayer before [now], used to show progress
  /// towards the next one.
  static PrayerTime previousPrayer(DateTime now) {
    PrayerTime? previous;
    for (final PrayerTime prayer in forDate(now).prayers) {
      if (prayer.isPrayer && !prayer.time.isAfter(now)) previous = prayer;
    }
    if (previous != null) return previous;
    return forDate(now.subtract(const Duration(days: 1))).prayers
        .lastWhere((PrayerTime prayer) => prayer.isPrayer);
  }
}

class PrayerSchedule {
  const PrayerSchedule({required this.date, required this.prayers});

  final DateTime date;
  final List<PrayerTime> prayers;
}
