// Reproduction test: the adhan sound step must appear in onboarding when
// reminders are enabled.

import 'package:athan_app/controllers/prayer_times_controller.dart';
import 'package:athan_app/controllers/theme_controller.dart';
import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/athan_sound.dart';
import 'package:athan_app/models/notification_settings.dart';
import 'package:athan_app/models/prayer_notification.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/screens/onboarding_screen.dart';
import 'package:athan_app/services/location_service.dart';
import 'package:athan_app/services/notification_service.dart';
import 'package:athan_app/services/settings_store.dart';
import 'package:athan_app/services/sound_preview_service.dart';
import 'package:athan_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool exactAlarmsAllowed = true;
  bool grantOnRequest = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> canScheduleExactNotifications() async => exactAlarmsAllowed;

  @override
  Future<bool> requestExactAlarmsPermission() async {
    if (grantOnRequest) exactAlarmsAllowed = true;
    return exactAlarmsAllowed;
  }

  @override
  Future<void> schedulePrayerNotifications({
    required List<PrayerNotification> notifications,
    AthanSound sound = AthanSound.system,
  }) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> showTestNotification({
    AthanSound sound = AthanSound.system,
  }) async {}
}

class _InMemorySettingsStore implements SettingsStore {
  PrayerSettings settings = const PrayerSettings();
  NotificationSettings notificationSettings = const NotificationSettings();
  AppThemeChoice theme = AppThemeChoice.emerald;
  bool autoTheme = false;
  List<AppLocation> locations = const <AppLocation>[];
  int activeIndex = 0;
  bool methodSaved = false;
  bool onboardingComplete = false;
  bool automaticLocation = true;

  @override
  Future<PrayerSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(PrayerSettings value) async => settings = value;

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
  Future<bool> loadAutomaticLocation() async => automaticLocation;

  @override
  Future<void> saveAutomaticLocation(bool value) async =>
      automaticLocation = value;

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

  @override
  Future<bool> loadAutoTheme() async => autoTheme;

  @override
  Future<void> saveAutoTheme(bool value) async => autoTheme = value;
}

class _FakeSoundPreviewService implements SoundPreviewService {
  final List<AthanSound> played = <AthanSound>[];

  @override
  Future<void> play(AthanSound sound) async => played.add(sound);

  @override
  Future<void> stop() async {}

  @override
  void setCompletionHandler(void Function(AthanSound sound)? handler) {}
}

Future<PrayerTimesController> _createController(
  _InMemorySettingsStore store,
  _FakeNotificationService notifications,
) async {
  final DateTime now = DateTime(2026, 11, 1, 10);
  final PrayerTimesController controller = PrayerTimesController(
    locationService: const _FakeLocationService(_london),
    settingsStore: store,
    notificationService: notifications,
    clock: () => now,
  );
  await controller.initialize();
  return controller;
}

void main() {
  testWidgets('sound step appears after enabling reminders', (
    WidgetTester tester,
  ) async {
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final _FakeNotificationService notifications = _FakeNotificationService();
    final PrayerTimesController controller = await _createController(
      store,
      notifications,
    );

    final ThemeController themeController = ThemeController(
      settingsStore: store,
    );
    await themeController.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forChoice(AppThemeChoice.emerald),
        home: OnboardingScreen(
          controller: controller,
          themeController: themeController,
          soundPreviewService: _FakeSoundPreviewService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Athan'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Prayer reminders'), findsOneWidget);

    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();

    expect(
      find.text('Athan sound'),
      findsOneWidget,
      reason:
          'The sound selection step should follow the notifications step '
          'when reminders are enabled.',
    );

    controller.dispose();
  });

  testWidgets('sound step appears after granting exact alarms', (
    WidgetTester tester,
  ) async {
    final _InMemorySettingsStore store = _InMemorySettingsStore();
    final _FakeNotificationService notifications = _FakeNotificationService()
      ..exactAlarmsAllowed = false
      ..grantOnRequest = true;
    final PrayerTimesController controller = await _createController(
      store,
      notifications,
    );

    final ThemeController themeController = ThemeController(
      settingsStore: store,
    );
    await themeController.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.forChoice(AppThemeChoice.emerald),
        home: OnboardingScreen(
          controller: controller,
          themeController: themeController,
          soundPreviewService: _FakeSoundPreviewService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Allow alarms & reminders'), findsOneWidget);

    await tester.tap(find.text('Allow exact alarms'));
    await tester.pumpAndSettle();

    expect(
      find.text('Athan sound'),
      findsOneWidget,
      reason:
          'After granting exact alarms, the alarms step is removed from '
          'the step list and the sound step must not be skipped.',
    );

    controller.dispose();
  });
}
