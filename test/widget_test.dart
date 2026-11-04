import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/app.dart';
import 'package:athan_app/controllers/prayer_times_controller.dart';
import 'package:athan_app/controllers/theme_controller.dart';
import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/athan_sound.dart';
import 'package:athan_app/models/notification_settings.dart';
import 'package:athan_app/models/prayer.dart';
import 'package:athan_app/models/prayer_notification.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/screens/manual_location_screen.dart';
import 'package:athan_app/screens/onboarding_screen.dart';
import 'package:athan_app/screens/qibla_screen.dart';
import 'package:athan_app/screens/settings_screen.dart';
import 'package:athan_app/services/compass_service.dart';
import 'package:athan_app/services/location_search_service.dart';
import 'package:athan_app/services/location_service.dart';
import 'package:athan_app/services/notification_service.dart';
import 'package:athan_app/services/prayer_times_service.dart';
import 'package:athan_app/services/settings_store.dart';
import 'package:athan_app/services/sound_preview_service.dart';
import 'package:athan_app/theme/app_theme.dart';
import 'package:athan_app/utils/qibla.dart';

const AppLocation _london = AppLocation(
  name: 'London, United Kingdom',
  latitude: 51.5074,
  longitude: -0.1278,
  isResolved: true,
);

const AppLocation _newYork = AppLocation(
  name: 'New York, United States',
  latitude: 40.7128,
  longitude: -74.006,
  countryCode: 'US',
  isResolved: true,
);

const AppLocation _paris = AppLocation(
  name: 'Paris, France',
  latitude: 48.8566,
  longitude: 2.3522,
  isResolved: true,
);

class _FakeLocationService implements LocationService {
  const _FakeLocationService(this.location);

  final AppLocation location;

  @override
  Future<AppLocation> currentLocation() async => location;
}

class _DeniedLocationService implements LocationService {
  const _DeniedLocationService();

  @override
  Future<AppLocation> currentLocation() async {
    throw const LocationException('Location permission was denied.');
  }
}

class _InMemorySettingsStore implements SettingsStore {
  PrayerSettings settings = const PrayerSettings();
  NotificationSettings notificationSettings = const NotificationSettings();
  AppThemeChoice theme = AppThemeChoice.emerald;
  List<AppLocation> locations = const <AppLocation>[];
  int activeIndex = 0;
  bool methodSaved = false;
  bool onboardingComplete = false;

  @override
  Future<PrayerSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(PrayerSettings value) async {
    settings = value;
    methodSaved = true;
  }

  @override
  Future<bool> hasSavedMethod() async => methodSaved;

  @override
  Future<SavedLocationState> loadLocations() async =>
      (locations: locations, activeIndex: activeIndex);

  @override
  Future<void> saveLocations(SavedLocationState state) async {
    locations = state.locations;
    activeIndex = state.activeIndex;
  }

  @override
  Future<bool> loadOnboardingComplete() async => onboardingComplete;

  @override
  Future<void> saveOnboardingComplete(bool value) async =>
      onboardingComplete = value;

  @override
  Future<NotificationSettings> loadNotificationSettings() async =>
      notificationSettings;

  @override
  Future<void> saveNotificationSettings(NotificationSettings value) async =>
      notificationSettings = value;

  @override
  Future<AppThemeChoice> loadTheme() async => theme;

  @override
  Future<void> saveTheme(AppThemeChoice value) async => theme = value;
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

class _FakeCompassService implements CompassService {
  _FakeCompassService(this.controller);

  final StreamController<CompassReading> controller;

  @override
  Stream<CompassReading> headingStream() => controller.stream;
}

class _FakeSoundPreviewService implements SoundPreviewService {
  final List<AthanSound> played = <AthanSound>[];
  AthanSound? playing;

  @override
  Future<void> play(AthanSound sound) async {
    played.add(sound);
    playing = sound;
  }

  @override
  Future<void> stop() async => playing = null;

  @override
  void setCompletionHandler(void Function(AthanSound sound)? handler) {}
}

class _FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool exactAlarmsAllowed = true;
  bool cancelled = false;
  int testNotifications = 0;
  int permissionRequests = 0;
  List<PrayerNotification> scheduled = <PrayerNotification>[];
  AthanSound? lastScheduledSound;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<bool> canScheduleExactNotifications() async => exactAlarmsAllowed;

  @override
  Future<bool> requestExactAlarmsPermission() async => exactAlarmsAllowed;

  @override
  Future<void> schedulePrayerNotifications({
    required List<PrayerNotification> notifications,
    AthanSound sound = AthanSound.system,
  }) async {
    scheduled = notifications;
    lastScheduledSound = sound;
  }

  @override
  Future<void> cancelAll() async {
    cancelled = true;
    scheduled = <PrayerNotification>[];
  }

  @override
  Future<void> showTestNotification({
    AthanSound sound = AthanSound.system,
  }) async => testNotifications++;
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
    ThemeController themeController,
    _InMemorySettingsStore store,
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
  final _InMemorySettingsStore store = _InMemorySettingsStore()
    ..onboardingComplete = true;
  final PrayerTimesController controller = PrayerTimesController(
    locationService: const _FakeLocationService(_london),
    settingsStore: store,
    notificationService: fake,
    locationSearchService: search,
    clock: () => now,
  );
  final ThemeController themeController = ThemeController(settingsStore: store);
  await controller.initialize();
  await themeController.initialize();
  return (
    controller: controller,
    fake: fake,
    search: search,
    themeController: themeController,
    store: store,
  );
}

void main() {
  testWidgets('home screen shows location, dates and calculated prayers', (
    WidgetTester tester,
  ) async {
    final result = await _createController();
    final PrayerTimesController controller = result.controller;

    await tester.pumpWidget(
      AthanApp(controller: controller, themeController: result.themeController),
    );
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

    await tester.pumpWidget(
      AthanApp(controller: controller, themeController: result.themeController),
    );
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

    await tester.pumpWidget(
      AthanApp(controller: controller, themeController: result.themeController),
    );
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

  test('first launch picks ISNA for a device location in the US', () async {
    const AppLocation newYork = AppLocation(
      name: 'New York, United States',
      latitude: 40.7128,
      longitude: -74.006,
      countryCode: 'US',
      isResolved: true,
    );
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(newYork),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );

    await controller.initialize();
    // The intro's location step resolves the position.
    await controller.refreshLocation();

    expect(controller.settings.method, PrayerMethod.northAmerica);
    expect(store.settings.method, PrayerMethod.northAmerica);

    controller.dispose();
  });

  test('first launch manual location picks the regional method', () async {
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _DeniedLocationService(),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );
    await controller.initialize();

    const AppLocation makkah = AppLocation(
      name: 'Makkah, Saudi Arabia',
      latitude: 21.4225,
      longitude: 39.8262,
      countryCode: 'SA',
    );
    await controller.setManualLocation(makkah);

    expect(controller.settings.method, PrayerMethod.ummAlQura);
    expect(store.settings.method, PrayerMethod.ummAlQura);

    controller.dispose();
  });

  test('a method chosen by the user is never overridden', () async {
    final _InMemorySettingsStore store = _InMemorySettingsStore()
      ..settings = const PrayerSettings(method: PrayerMethod.egyptian)
      ..methodSaved = true;
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(_newYork),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );

    await controller.initialize();
    await controller.refreshLocation();

    expect(controller.settings.method, PrayerMethod.egyptian);

    controller.dispose();
  });

  test('returning users keep their method on later launches', () async {
    final _InMemorySettingsStore store = _InMemorySettingsStore()
      ..locations = <AppLocation>[_newYork];
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(_newYork),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );

    await controller.initialize();

    expect(controller.settings.method, PrayerMethod.muslimWorldLeague);

    controller.dispose();
  });

  test('completing the intro persists the flag', () async {
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _DeniedLocationService(),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );

    await controller.initialize();
    expect(controller.isOnboardingComplete, isFalse);

    await controller.completeOnboarding();

    expect(controller.isOnboardingComplete, isTrue);
    expect(store.onboardingComplete, isTrue);

    controller.dispose();
  });

  test('users with a saved location skip the intro without the flag', () async {
    final _InMemorySettingsStore store = _InMemorySettingsStore()
      ..locations = <AppLocation>[_newYork];
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(_newYork),
      settingsStore: store,
      notificationService: _FakeNotificationService(),
      clock: _midMorning,
    );

    await controller.initialize();

    expect(controller.isOnboardingComplete, isTrue);

    controller.dispose();
  });

  test(
    'the notification permission is only requested from the intro button',
    () async {
      final _InMemorySettingsStore store = _InMemorySettingsStore();
      final _FakeNotificationService fake = _FakeNotificationService();
      final PrayerTimesController controller = PrayerTimesController(
        locationService: const _DeniedLocationService(),
        settingsStore: store,
        notificationService: fake,
        clock: _midMorning,
      );

      await controller.initialize();

      // Reminders default to enabled, but a first launch must not prompt.
      expect(controller.notifications.enabled, isTrue);
      expect(fake.permissionRequests, 0);

      // The intro's enable button triggers the system dialog.
      await controller.setNotificationsEnabled(true);
      expect(fake.permissionRequests, 1);
      expect(controller.notificationsReady, isTrue);

      controller.dispose();
    },
  );

  test(
    'set-up users are asked for the notification permission at launch',
    () async {
      final _InMemorySettingsStore store = _InMemorySettingsStore()
        ..onboardingComplete = true;
      final _FakeNotificationService fake = _FakeNotificationService();
      final PrayerTimesController controller = PrayerTimesController(
        locationService: const _FakeLocationService(_newYork),
        settingsStore: store,
        notificationService: fake,
        clock: _midMorning,
      );

      await controller.initialize();

      expect(fake.permissionRequests, 1);
      expect(controller.notificationsReady, isTrue);

      controller.dispose();
    },
  );

  test(
    'setManualLocation adds a second saved location and switches to it',
    () async {
      final result = await _createController();
      expect(result.controller.savedLocations, hasLength(1));

      await result.controller.setManualLocation(_paris);

      expect(result.controller.savedLocations, hasLength(2));
      expect(result.controller.activeLocationIndex, 1);
      expect(result.controller.location.name, 'Paris, France');
      expect(result.store.locations, hasLength(2));
      expect(result.store.activeIndex, 1);

      result.controller.dispose();
    },
  );

  test('re-selecting a stored location switches to it', () async {
    final result = await _createController();
    await result.controller.setManualLocation(_paris);

    await result.controller.setManualLocation(_london);

    expect(result.controller.savedLocations, hasLength(2));
    expect(result.controller.activeLocationIndex, 0);
    expect(result.controller.location.name, 'London, United Kingdom');

    result.controller.dispose();
  });

  test(
    'a new place replaces the active location when both slots are used',
    () async {
      final result = await _createController();
      await result.controller.setManualLocation(_paris);

      const AppLocation berlin = AppLocation(
        name: 'Berlin, Germany',
        latitude: 52.52,
        longitude: 13.405,
      );
      await result.controller.setManualLocation(berlin);

      expect(result.controller.savedLocations, hasLength(2));
      expect(result.controller.location.name, 'Berlin, Germany');
      expect(
        result.controller.savedLocations[0].name,
        'London, United Kingdom',
      );
      expect(result.controller.savedLocations[1].name, 'Berlin, Germany');

      result.controller.dispose();
    },
  );

  test(
    'switchLocation shows prayer times for the other saved location',
    () async {
      final result = await _createController();
      await result.controller.setManualLocation(_paris);

      final DateTime parisDhuhr = result.controller.day.schedule.prayers
          .firstWhere((PrayerTime prayer) => prayer.id == PrayerId.dhuhr)
          .time;

      await result.controller.switchLocation(0);

      final DateTime londonDhuhr = result.controller.day.schedule.prayers
          .firstWhere((PrayerTime prayer) => prayer.id == PrayerId.dhuhr)
          .time;
      expect(result.controller.activeLocationIndex, 0);
      expect(result.controller.location.name, 'London, United Kingdom');
      expect(result.store.activeIndex, 0);
      expect(londonDhuhr, isNot(parisDhuhr));

      result.controller.dispose();
    },
  );

  test('removeLocation deletes the secondary location', () async {
    final result = await _createController();
    await result.controller.setManualLocation(_paris);

    await result.controller.removeLocation(1);

    expect(result.controller.savedLocations, hasLength(1));
    expect(result.controller.location.name, 'London, United Kingdom');
    expect(result.controller.activeLocationIndex, 0);
    expect(result.store.locations, hasLength(1));
    expect(result.store.activeIndex, 0);

    result.controller.dispose();
  });

  test(
    'removing the active location falls back to the remaining one',
    () async {
      final result = await _createController();
      await result.controller.setManualLocation(_paris);

      await result.controller.removeLocation(1);

      expect(result.controller.location.name, 'London, United Kingdom');
      expect(result.controller.savedLocations, hasLength(1));

      result.controller.dispose();
    },
  );

  test(
    'removing the active location switches to the other saved one',
    () async {
      final result = await _createController();
      await result.controller.setManualLocation(_paris);
      await result.controller.switchLocation(0);

      await result.controller.removeLocation(0);

      expect(result.controller.savedLocations, hasLength(1));
      expect(result.controller.activeLocationIndex, 0);
      expect(result.controller.location.name, 'Paris, France');
      expect(result.store.activeIndex, 0);

      result.controller.dispose();
    },
  );

  test('the last remaining location cannot be removed', () async {
    final result = await _createController();

    await result.controller.removeLocation(0);

    expect(result.controller.savedLocations, hasLength(1));
    expect(result.controller.location.name, 'London, United Kingdom');

    result.controller.dispose();
  });

  testWidgets('the location sheet offers adding a second location', (
    WidgetTester tester,
  ) async {
    final result = await _createController();

    await tester.pumpWidget(
      AthanApp(
        controller: result.controller,
        themeController: result.themeController,
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Add second location'), findsOneWidget);

    await tester.tap(find.text('Add second location'));
    await tester.pumpAndSettle();

    expect(find.text('Enter location'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    result.controller.dispose();
  });

  testWidgets('first launch shows the intro and completes setup', (
    WidgetTester tester,
  ) async {
    final DateTime now = _midMorning();
    final _FakeNotificationService fake = _FakeNotificationService();
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final _FakeLocationSearchService search = _FakeLocationSearchService(
      const <AppLocation>[_paris],
    );
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(_london),
      settingsStore: store,
      notificationService: fake,
      locationSearchService: search,
      clock: () => now,
    );
    final ThemeController themeController = ThemeController(
      settingsStore: store,
    );
    await controller.initialize();
    await themeController.initialize();

    await tester.pumpWidget(
      AthanApp(controller: controller, themeController: themeController),
    );
    await tester.pump();

    // Welcome step.
    expect(find.text('Welcome to Athan'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Notifications step.
    expect(find.text('Prayer reminders'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(controller.notifications.enabled, isFalse);

    // The adhan sound step is skipped when reminders stay off.
    expect(find.text('Athan sound'), findsNothing);

    // Location step: enter a place manually.
    expect(find.text('Your location'), findsOneWidget);
    await tester.tap(find.text('Enter it manually'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('Paris, France'));
    await tester.pumpAndSettle();

    // Theme step.
    expect(find.text('Pick a theme'), findsOneWidget);
    await tester.tap(find.text('Sky'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // The home screen shows the chosen location and theme.
    expect(find.text('Paris, France'), findsOneWidget);
    expect(controller.isOnboardingComplete, isTrue);
    expect(store.onboardingComplete, isTrue);
    expect(themeController.choice, AppThemeChoice.sky);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('the intro offers an adhan sound when reminders are enabled', (
    WidgetTester tester,
  ) async {
    final DateTime now = _midMorning();
    final _FakeNotificationService fake = _FakeNotificationService();
    final _FakeSoundPreviewService previews = _FakeSoundPreviewService();
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final PrayerTimesController controller = PrayerTimesController(
      locationService: const _FakeLocationService(_london),
      settingsStore: store,
      notificationService: fake,
      clock: () => now,
    );
    final ThemeController themeController = ThemeController(
      settingsStore: store,
    );
    await controller.initialize();
    await themeController.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: OnboardingScreen(
          controller: controller,
          themeController: themeController,
          soundPreviewService: previews,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();

    // The sound step follows the notifications step.
    expect(find.text('Athan sound'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Makkah - Ali Mullah'), findsOneWidget);
    expect(find.text('Madina - Muhammad Qassas'), findsOneWidget);

    // Preview the Makkah adhan.
    await tester.tap(find.byTooltip('Preview Makkah - Ali Mullah'));
    await tester.pump();
    expect(previews.played, contains(AthanSound.makkahAliMullah));
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    // Select it and continue to the location step.
    await tester.tap(find.text('Makkah - Ali Mullah'));
    await tester.pump();
    expect(controller.notifications.sound, AthanSound.makkahAliMullah);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(previews.playing, isNull);
    expect(find.text('Your location'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
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
        home: SettingsScreen(
          controller: controller,
          themeController: result.themeController,
        ),
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

  testWidgets('qibla screen shows the bearing and reacts to the compass', (
    WidgetTester tester,
  ) async {
    final result = await _createController();
    final PrayerTimesController controller = result.controller;
    final StreamController<CompassReading> compassController =
        StreamController<CompassReading>.broadcast();
    final _FakeCompassService compass = _FakeCompassService(compassController);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QiblaScreen(controller: controller, compassService: compass),
      ),
    );
    await tester.pump();

    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('119°'), findsOneWidget);
    expect(find.text('Waiting for the compass…'), findsOneWidget);

    compassController.add(const CompassReading(heading: 0));
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Turn your phone until the Kaaba marker is at the top.'),
      findsOneWidget,
    );

    compassController.add(
      CompassReading(heading: qiblaBearing(controller.location)),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('You are facing the Qibla.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await compassController.close();
    controller.dispose();
  });

  testWidgets('settings can change the theme', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final result = await _createController();
    final PrayerTimesController controller = result.controller;
    final ThemeController themeController = result.themeController;

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: themeController,
        builder: (BuildContext context, Widget? _) => MaterialApp(
          theme: AppTheme.forChoice(themeController.choice),
          home: SettingsScreen(
            controller: controller,
            themeController: themeController,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Emerald'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sakura'), findsOneWidget);
    await tester.tap(find.text('Sakura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(themeController.choice, AppThemeChoice.sakura);
    final BuildContext settingsContext = tester.element(
      find.byType(SettingsScreen),
    );
    expect(settingsContext.palette.primary, AppPalettes.sakura.primary);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    themeController.dispose();
  });

  testWidgets('settings can pick the athan sound', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final result = await _createController();
    final PrayerTimesController controller = result.controller;
    final _FakeNotificationService fake = result.fake;

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _) => MaterialApp(
          theme: AppTheme.light,
          home: SettingsScreen(
            controller: controller,
            themeController: result.themeController,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('System default'), findsOneWidget);

    await tester.tap(find.text('Athan sound'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Makkah - Ali Mullah'), findsOneWidget);
    expect(find.text('Madina - Muhammad Qassas'), findsOneWidget);

    await tester.tap(find.text('Makkah - Ali Mullah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(controller.notifications.sound, AthanSound.makkahAliMullah);
    expect(fake.lastScheduledSound, AthanSound.makkahAliMullah);
    expect(find.text('Makkah - Ali Mullah'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
