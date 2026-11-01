import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/app.dart';
import 'package:athan_app/controllers/prayer_times_controller.dart';
import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/notification_settings.dart';
import 'package:athan_app/models/prayer.dart';
import 'package:athan_app/models/prayer_notification.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/screens/manual_location_screen.dart';
import 'package:athan_app/screens/settings_screen.dart';
import 'package:athan_app/services/location_search_service.dart';
import 'package:athan_app/services/location_service.dart';
import 'package:athan_app/services/notification_service.dart';
import 'package:athan_app/services/prayer_times_service.dart';
import 'package:athan_app/services/settings_store.dart';
import 'package:athan_app/theme/app_theme.dart';

const AppLocation _london = AppLocation(
  name: 'London, United Kingdom',
  latitude: 51.5074,
  longitude: -0.1278,
  isResolved: true,
);

class _FakeLocationService implements LocationService {
  const _FakeLocationService(this.location);

  final AppLocation location;

  @override
  Future<AppLocation> currentLocation() async => location;
}

class _InMemorySettingsStore implements SettingsStore {
  PrayerSettings settings = const PrayerSettings();
  NotificationSettings notificationSettings = const NotificationSettings();
  AppLocation? location;

  @override
  Future<PrayerSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(PrayerSettings value) async => settings = value;

  @override
  Future<AppLocation?> loadLocation() async => location;

  @override
  Future<void> saveLocation(AppLocation value) async => location = value;

  @override
  Future<NotificationSettings> loadNotificationSettings() async =>
      notificationSettings;

  @override
  Future<void> saveNotificationSettings(NotificationSettings value) async =>
      notificationSettings = value;
}

class _FakeLocationSearchService implements LocationSearchService {
  _FakeLocationSearchService(this.results);

  final List<AppLocation> results;
  String? lastQuery;

  @override
  Future<List<AppLocation>> search(String query) async {
    lastQuery = query;
    return results;
  }
}

class _FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool exactAlarmsAllowed = true;
  bool cancelled = false;
  int testNotifications = 0;
  List<PrayerNotification> scheduled = <PrayerNotification>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> canScheduleExactNotifications() async => exactAlarmsAllowed;

  @override
  Future<bool> requestExactAlarmsPermission() async => exactAlarmsAllowed;

  @override
  Future<void> schedulePrayerNotifications({
    required List<PrayerNotification> notifications,
  }) async {
    scheduled = notifications;
  }

  @override
  Future<void> cancelAll() async {
    cancelled = true;
    scheduled = <PrayerNotification>[];
  }

  @override
  Future<void> showTestNotification() async => testNotifications++;
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

Future<
  ({
    PrayerTimesController controller,
    _FakeNotificationService fake,
    _FakeLocationSearchService search,
  })
>
_createController({
  List<AppLocation> searchResults = const <AppLocation>[],
}) async {
  final DateTime now = _midMorning();
  final _FakeNotificationService fake = _FakeNotificationService();
  final _FakeLocationSearchService search = _FakeLocationSearchService(
    searchResults,
  );
  final PrayerTimesController controller = PrayerTimesController(
    locationService: const _FakeLocationService(_london),
    settingsStore: _InMemorySettingsStore(),
    notificationService: fake,
    locationSearchService: search,
    clock: () => now,
  );
  await controller.initialize();
  return (controller: controller, fake: fake, search: search);
}

void main() {
  testWidgets('home screen shows location, dates and calculated prayers', (
    WidgetTester tester,
  ) async {
    final result = await _createController();
    final PrayerTimesController controller = result.controller;

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
    final result = await _createController();
    final PrayerTimesController controller = result.controller;

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

  testWidgets('muting a prayer removes its scheduled reminder', (
    WidgetTester tester,
  ) async {
    final result = await _createController();
    final PrayerTimesController controller = result.controller;
    final _FakeNotificationService fake = result.fake;

    await tester.pumpWidget(AthanApp(controller: controller));
    await tester.pump();

    expect(
      fake.scheduled.any(
        (PrayerNotification notification) =>
            notification.prayer == PrayerId.fajr,
      ),
      isTrue,
    );

    // The first bell in the list belongs to Fajr.
    await tester.tap(find.byIcon(Icons.notifications_active_outlined).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(controller.notifications.muted, contains(PrayerId.fajr));
    expect(
      fake.scheduled.any(
        (PrayerNotification notification) =>
            notification.prayer == PrayerId.fajr,
      ),
      isFalse,
    );

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('manual location search updates the location', (
    WidgetTester tester,
  ) async {
    const AppLocation paris = AppLocation(
      name: 'Paris, France',
      latitude: 48.8566,
      longitude: 2.3522,
      isResolved: true,
    );
    final result = await _createController(
      searchResults: const <AppLocation>[paris],
    );
    final PrayerTimesController controller = result.controller;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ManualLocationScreen(controller: controller),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(result.search.lastQuery, 'Paris');
    expect(find.text('Paris, France'), findsOneWidget);

    await tester.tap(find.text('Paris, France'));
    await tester.pumpAndSettle();

    expect(controller.location.name, 'Paris, France');
    expect(controller.location.latitude, 48.8566);
    expect(controller.location.isResolved, isTrue);
    expect(find.text('Enter location'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  test('setManualLocation updates and persists the location', () async {
    final result = await _createController();
    const AppLocation paris = AppLocation(
      name: 'Paris, France',
      latitude: 48.8566,
      longitude: 2.3522,
    );

    await result.controller.setManualLocation(paris);

    expect(result.controller.location.name, 'Paris, France');
    expect(result.controller.location.isResolved, isTrue);
    expect(result.fake.scheduled, isNotEmpty);

    result.controller.dispose();
  });

  testWidgets('settings can disable all prayer reminders', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final result = await _createController();
    final PrayerTimesController controller = result.controller;
    final _FakeNotificationService fake = result.fake;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SettingsScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('Prayer reminders'), findsOneWidget);

    await tester.tap(find.text('Prayer reminders'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(controller.notifications.enabled, isFalse);
    expect(fake.cancelled, isTrue);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
