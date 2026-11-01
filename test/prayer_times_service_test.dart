import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/prayer.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/services/prayer_times_service.dart';

const AppLocation _london = AppLocation(
  name: 'London, United Kingdom',
  latitude: 51.5074,
  longitude: -0.1278,
);

void main() {
  const PrayerTimesService service = PrayerTimesService();

  test('prayer times are ordered and cover the whole day', () {
    final schedule = service.scheduleFor(
      date: DateTime(2026, 11, 1),
      location: _london,
      settings: const PrayerSettings(),
    );

    expect(
      schedule.prayers.map((PrayerTime prayer) => prayer.id),
      PrayerId.values,
    );

    for (int i = 1; i < schedule.prayers.length; i++) {
      expect(
        schedule.prayers[i].time.isAfter(schedule.prayers[i - 1].time),
        isTrue,
        reason:
            '${schedule.prayers[i].label} should be after '
            '${schedule.prayers[i - 1].label}',
      );
    }
  });

  test('next and previous prayers follow the current time', () {
    final schedule = service.scheduleFor(
      date: DateTime(2026, 11, 1),
      location: _london,
      settings: const PrayerSettings(),
    );
    final PrayerTime fajr = schedule.prayers.firstWhere(
      (PrayerTime prayer) => prayer.id == PrayerId.fajr,
    );
    final PrayerTime dhuhr = schedule.prayers.firstWhere(
      (PrayerTime prayer) => prayer.id == PrayerId.dhuhr,
    );
    final PrayerTime isha = schedule.prayers.last;

    final DateTime midMorning = fajr.time.add(
      dhuhr.time.difference(fajr.time) ~/ 2,
    );
    final day = service.dayFor(
      now: midMorning,
      location: _london,
      settings: const PrayerSettings(),
    );
    expect(day.next.id, PrayerId.dhuhr);
    expect(day.previous.id, PrayerId.fajr);

    final DateTime afterIsha = isha.time.add(const Duration(minutes: 5));
    final night = service.dayFor(
      now: afterIsha,
      location: _london,
      settings: const PrayerSettings(),
    );
    expect(night.next.id, PrayerId.fajr);
    expect(night.previous.id, PrayerId.isha);
    expect(night.next.time.isAfter(afterIsha), isTrue);
  });

  test('Hanafi Asr is later than the standard Asr', () {
    final standard = service.scheduleFor(
      date: DateTime(2026, 11, 1),
      location: _london,
      settings: const PrayerSettings(),
    );
    final hanafi = service.scheduleFor(
      date: DateTime(2026, 11, 1),
      location: _london,
      settings: const PrayerSettings(madhab: AsrMadhab.hanafi),
    );

    expect(hanafi.prayers[3].time.isAfter(standard.prayers[3].time), isTrue);
  });
}
