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
