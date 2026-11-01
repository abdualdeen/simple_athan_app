import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/app.dart';
import 'package:athan_app/controllers/prayer_times_controller.dart';
import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/prayer.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/services/location_service.dart';
import 'package:athan_app/services/prayer_times_service.dart';
import 'package:athan_app/services/settings_store.dart';

const AppLocation _london = AppLocation(
  name: 'London, United Kingdom',
  latitude: 51.5074,
  longitude: -0.1278,
  isDeviceLocation: true,
);

class _FakeLocationService implements LocationService {
  const _FakeLocationService(this.location);

  final AppLocation location;

  @override
  Future<AppLocation> currentLocation() async => location;
}

class _InMemorySettingsStore implements SettingsStore {
  PrayerSettings settings = const PrayerSettings();
  AppLocation? location;

  @override
  Future<PrayerSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(PrayerSettings value) async => settings = value;

  @override
  Future<AppLocation?> loadLocation() async => location;

  @override
  Future<void> saveLocation(AppLocation value) async => location = value;
}

/// A fixed "now" between Fajr and Dhuhr so the next prayer is deterministic
/// regardless of the machine's timezone.
DateTime _midMorning() {
  const PrayerTimesService service = PrayerTimesService();
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
  return fajr.time.add(dhuhr.time.difference(fajr.time) ~/ 2);
}

Future<PrayerTimesController> _controller() async {
  final DateTime now = _midMorning();
  final PrayerTimesController controller = PrayerTimesController(
    locationService: const _FakeLocationService(_london),
    settingsStore: _InMemorySettingsStore(),
    clock: () => now,
  );
  await controller.initialize();
  return controller;
}

void main() {
  testWidgets('home screen shows location, dates and calculated prayers', (
    WidgetTester tester,
  ) async {
    final PrayerTimesController controller = await _controller();

    await tester.pumpWidget(AthanApp(controller: controller));
    await tester.pump();

    expect(find.text('London, United Kingdom'), findsOneWidget);
    expect(find.text('Assalamu Alaikum'), findsOneWidget);
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Dhuhr'), findsNWidgets(2));
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('drawer opens settings and changes the Asr madhab', (
    WidgetTester tester,
  ) async {
    final PrayerTimesController controller = await _controller();

    await tester.pumpWidget(AthanApp(controller: controller));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Qibla Direction'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Update from device'), findsOneWidget);
    expect(find.text('Method'), findsOneWidget);

    await tester.tap(find.text('Hanafi'));
    await tester.pump();

    expect(controller.settings.madhab, AsrMadhab.hanafi);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
