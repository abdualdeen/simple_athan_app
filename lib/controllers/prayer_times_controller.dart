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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_location.dart';
import '../models/athan_sound.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_notification.dart';
import '../models/prayer_schedule.dart';
import '../models/prayer_settings.dart';
import '../services/location_search_service.dart';
import '../services/location_service.dart';
import '../services/home_widget_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_notification_builder.dart';
import '../services/prayer_times_service.dart';
import '../services/settings_store.dart';
import '../utils/suggested_method.dart';

/// Owns the app's location, calculation settings, notifications, and the
/// current prayer day.
class PrayerTimesController extends ChangeNotifier {
  PrayerTimesController({
    required LocationService locationService,
    required SettingsStore settingsStore,
    required NotificationService notificationService,
    LocationSearchService locationSearchService =
        const GeocodingLocationSearchService(),
    PrayerTimesService prayerTimesService = const PrayerTimesService(),
    HomeWidgetService homeWidgetService = const HomeWidgetService(),
    DateTime Function()? clock,
  }) : this._(
         locationService,
         settingsStore,
         notificationService,
         locationSearchService,
         prayerTimesService,
         homeWidgetService,
         clock ?? DateTime.now,
       );

  PrayerTimesController._(
    this._locationService,
    this._settingsStore,
    this._notificationService,
    this._locationSearchService,
    this._prayerTimesService,
    this._homeWidgetService,
    this._clock,
  ) : _now = _clock();

  final LocationService _locationService;
  final SettingsStore _settingsStore;
  final NotificationService _notificationService;
  final LocationSearchService _locationSearchService;
  final PrayerTimesService _prayerTimesService;
  final HomeWidgetService _homeWidgetService;
  final DateTime Function() _clock;

  List<AppLocation> _savedLocations = const <AppLocation>[];
  int _activeLocationIndex = 0;
  PrayerSettings _settings = const PrayerSettings();
  NotificationSettings _notifications = const NotificationSettings();
  PrayerDay? _day;
  bool _isInitializing = true;
  bool _isLocating = false;
  bool _notificationsReady = false;
  bool _exactAlarmsAllowed = false;
  bool _isSyncingNotifications = false;
  bool _syncPending = false;
  bool _isFirstLaunch = false;
  bool _onboardingComplete = false;
  bool _useAutomaticLocation = true;
  String? _locationError;
  Timer? _ticker;
  DateTime _now;
  bool _disposed = false;

  DateTime get now => _now;
  AppLocation get location {
    if (_savedLocations.isEmpty) return AppLocation.makkah;
    return _savedLocations[_activeLocationIndex.clamp(
      0,
      _savedLocations.length - 1,
    )];
  }

  /// The stored locations the user can switch between (at most two).
  List<AppLocation> get savedLocations => List.unmodifiable(_savedLocations);

  /// The index into [savedLocations] currently shown.
  int get activeLocationIndex => _activeLocationIndex;
  PrayerSettings get settings => _settings;
  NotificationSettings get notifications => _notifications;
  PrayerDay get day => _day ??= _computeDay();

  /// Whether the sun is down at the shown location: before today's sunrise
  /// or after today's Maghrib. Used by the auto night theme.
  bool get isNight {
    final PrayerDay current = day;
    final DateTime sunrise = current.schedule.prayers
        .firstWhere((PrayerTime prayer) => prayer.id == PrayerId.sunrise)
        .time;
    final DateTime maghrib = current.schedule.prayers
        .firstWhere((PrayerTime prayer) => prayer.id == PrayerId.maghrib)
        .time;
    return now.isBefore(sunrise) || now.isAfter(maghrib);
  }

  bool get isInitializing => _isInitializing;
  bool get isLocating => _isLocating;
  bool get notificationsReady => _notificationsReady;
  bool get exactAlarmsAllowed => _exactAlarmsAllowed;
  String? get locationError => _locationError;

  /// Whether the first-launch intro has been finished. Users with a saved
  /// location from before the intro existed count as complete.
  bool get isOnboardingComplete => _onboardingComplete;

  /// Whether the app may refresh the device's position on launch. The refresh
  /// only runs when the shown location was itself found by the device, so a
  /// place the user picked by hand is never replaced automatically.
  bool get useAutomaticLocation => _useAutomaticLocation;

  /// Loads saved settings and location, then refreshes the device's position
  /// when automatic location is on and the shown location came from the
  /// device.
  Future<void> initialize() async {
    try {
      _settings = await _settingsStore.loadSettings();
      _notifications = await _settingsStore.loadNotificationSettings();
      final SavedLocationState saved = await _settingsStore.loadLocations();
      _isFirstLaunch = saved.locations.isEmpty;
      _savedLocations = saved.locations;
      _activeLocationIndex = saved.activeIndex;
      _useAutomaticLocation = await _settingsStore.loadAutomaticLocation();
      _onboardingComplete =
          _savedLocations.isNotEmpty ||
          await _settingsStore.loadOnboardingComplete();
    } catch (error) {
      debugPrint('Failed to load saved settings: $error');
    }

    _isInitializing = false;
    _day = null;
    _notify();
    _startTicker();

    await _prepareNotifications();

    if (_savedLocations.isNotEmpty) {
      if (_useAutomaticLocation && location.fromDevice) {
        await refreshLocation();
      } else {
        await syncNotifications();
      }
    } else if (_onboardingComplete && _useAutomaticLocation) {
      await refreshLocation();
    }
  }

  /// Marks the first-launch intro as finished. Locations set during the intro
  /// have already been resolved; if not, fetches one now.
  ///
  /// The automatic-location setting starts matching how the user resolved
  /// their location: a manual pick turns it off, a device fix (or none yet)
  /// keeps it on.
  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    _useAutomaticLocation = location.fromDevice;
    _notify();
    try {
      await _settingsStore.saveOnboardingComplete(true);
      await _settingsStore.saveAutomaticLocation(_useAutomaticLocation);
    } catch (error) {
      debugPrint('Failed to save onboarding state: $error');
    }
    if (!location.isResolved) {
      await refreshLocation();
    } else {
      unawaited(_pushHomeWidget());
    }
  }

  Future<void> refreshLocation() async {
    if (_isLocating) return;
    _isLocating = true;
    _locationError = null;
    _notify();

    try {
      final AppLocation location = await _locationService.currentLocation();
      _upsertLocation(location);
      _day = null;
      await _applySuggestedMethod();
      await _saveLocations();
    } on LocationException catch (error) {
      _locationError = error.message;
    } catch (error) {
      debugPrint('Location lookup failed: $error');
      _locationError = 'Could not determine your location. Please try again.';
    } finally {
      _isLocating = false;
      _notify();
    }

    await syncNotifications();
  }

  /// Looks up places by name, or parses `latitude, longitude` input.
  Future<List<AppLocation>> searchLocations(String query) =>
      _locationSearchService.search(query);

  /// Turns the automatic location setting on or off. Enabling it refreshes
  /// the position straight away when the shown location came from the device;
  /// a manually chosen place is left alone.
  Future<void> setAutomaticLocation(bool enabled) async {
    if (_useAutomaticLocation == enabled) return;
    _useAutomaticLocation = enabled;
    _notify();
    await _settingsStore.saveAutomaticLocation(enabled);
    if (enabled && location.fromDevice) {
      await refreshLocation();
    }
  }

  /// Uses a location chosen by the user instead of the device's position.
  ///
  /// A place that is already stored is switched to; otherwise it fills the
  /// free slot, or replaces the active location when both slots are in use.
  Future<void> setManualLocation(AppLocation location) async {
    _upsertLocation(location.copyWith(isResolved: true));
    _locationError = null;
    _day = null;
    await _applySuggestedMethod();
    _notify();
    await _saveLocations();
    await syncNotifications();
  }

  /// Shows prayer times for the stored location at [index].
  Future<void> switchLocation(int index) async {
    if (index < 0 || index >= _savedLocations.length) return;
    if (index == _activeLocationIndex) return;
    _activeLocationIndex = index;
    _locationError = null;
    _day = null;
    _notify();
    await _saveLocations();
    await syncNotifications();
  }

  /// Removes the stored location at [index], keeping at least one location.
  /// If the removed one was shown, the remaining location becomes active.
  Future<void> removeLocation(int index) async {
    if (index < 0 || index >= _savedLocations.length) return;
    if (_savedLocations.length <= 1) return;
    _savedLocations = List<AppLocation>.of(_savedLocations)..removeAt(index);
    if (_activeLocationIndex >= _savedLocations.length) {
      _activeLocationIndex = _savedLocations.length - 1;
    } else if (index < _activeLocationIndex) {
      _activeLocationIndex--;
    }
    _day = null;
    _notify();
    await _saveLocations();
    await syncNotifications();
  }

  /// Stores [location] in the first free slot, or replaces the active entry
  /// when both slots are used. Re-selecting a stored place just switches to
  /// it instead of duplicating it.
  void _upsertLocation(AppLocation location) {
    final int existing = _indexOfSamePlace(location);
    if (existing >= 0) {
      final List<AppLocation> updated = List<AppLocation>.of(_savedLocations);
      updated[existing] = location;
      _savedLocations = updated;
      _activeLocationIndex = existing;
      return;
    }
    if (_savedLocations.length < 2) {
      _savedLocations = List<AppLocation>.of(_savedLocations)..add(location);
      _activeLocationIndex = _savedLocations.length - 1;
      return;
    }
    // Both slots are used and this is a new place. A device refresh must
    // update the device-tracked slot rather than the place the user picked
    // by hand; a manual pick replaces the shown location.
    final int target;
    if (location.fromDevice) {
      final int deviceSlot = _savedLocations.indexWhere(
        (AppLocation saved) => saved.fromDevice,
      );
      target = deviceSlot >= 0 ? deviceSlot : _activeLocationIndex;
    } else {
      target = _activeLocationIndex;
    }
    final List<AppLocation> updated = List<AppLocation>.of(_savedLocations);
    updated[target] = location;
    _savedLocations = updated;
    _activeLocationIndex = target;
  }

  int _indexOfSamePlace(AppLocation location) {
    for (int i = 0; i < _savedLocations.length; i++) {
      final AppLocation saved = _savedLocations[i];
      if ((saved.latitude - location.latitude).abs() < 0.01 &&
          (saved.longitude - location.longitude).abs() < 0.01) {
        return i;
      }
    }
    return -1;
  }

  Future<void> _saveLocations() async {
    await _settingsStore.saveLocations((
      locations: _savedLocations,
      activeIndex: _activeLocationIndex,
    ));
  }

  /// On the first launch, once a location is known (from the device or picked
  /// manually), selects the calculation method commonly used there, such as
  /// ISNA in North America. Never overrides a method the user already chose.
  Future<void> _applySuggestedMethod() async {
    if (!_isFirstLaunch || !location.isResolved) return;
    _isFirstLaunch = false;
    try {
      if (await _settingsStore.hasSavedMethod()) return;
      final PrayerMethod suggested = suggestedMethodFor(location);
      if (suggested == _settings.method) return;
      _settings = _settings.copyWith(method: suggested);
      _day = null;
      await _settingsStore.saveSettings(_settings);
      _notify();
    } catch (error) {
      debugPrint('Could not apply the suggested calculation method: $error');
    }
  }

  Future<void> updateSettings(PrayerSettings settings) async {
    _settings = settings;
    _day = null;
    _notify();
    await _settingsStore.saveSettings(settings);
    await syncNotifications();
  }

  Future<void> togglePrayerNotification(PrayerId id) async {
    _notifications = _notifications.togglePrayer(id);
    _notify();
    await _settingsStore.saveNotificationSettings(_notifications);
    await syncNotifications();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notifications = _notifications.copyWith(enabled: enabled);
    _notify();
    await _settingsStore.saveNotificationSettings(_notifications);

    if (!enabled) {
      await _notificationService.cancelAll();
      return;
    }
    if (!_notificationsReady) {
      await requestNotificationPermission();
    } else {
      await syncNotifications();
    }
  }

  /// Switches the adhan sound used by prayer notifications.
  Future<void> setNotificationSound(AthanSound sound) async {
    if (_notifications.sound == sound) return;
    _notifications = _notifications.copyWith(sound: sound);
    _notify();
    await _settingsStore.saveNotificationSettings(_notifications);
    await syncNotifications();
  }

  Future<bool> requestNotificationPermission() async {
    try {
      _notificationsReady = await _notificationService.requestPermission();
      _exactAlarmsAllowed = await _notificationService
          .canScheduleExactNotifications();
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
      _notificationsReady = false;
    }
    _notify();
    if (_notificationsReady) await syncNotifications();
    return _notificationsReady;
  }

  Future<void> requestExactAlarms() async {
    try {
      _exactAlarmsAllowed = await _notificationService
          .requestExactAlarmsPermission();
    } catch (error) {
      debugPrint('Exact alarm permission request failed: $error');
    }
    _notify();
    await syncNotifications();
  }

  Future<void> sendTestNotification() async {
    if (!_notificationsReady) {
      final bool granted = await requestNotificationPermission();
      if (!granted) return;
    }
    try {
      await _notificationService.showTestNotification(
        sound: _notifications.sound,
      );
    } catch (error) {
      debugPrint('Test notification failed: $error');
    }
  }

  /// Rebuilds the rolling window of scheduled prayer reminders.
  Future<void> syncNotifications() async {
    // The widget shows times even when reminders are off, so it is pushed
    // before the notification early-returns.
    unawaited(_pushHomeWidget());
    if (_disposed || !_notificationsReady || !location.isResolved) {
      return;
    }
    if (_isSyncingNotifications) {
      _syncPending = true;
      return;
    }

    _isSyncingNotifications = true;
    try {
      do {
        _syncPending = false;
        final List<PrayerNotification> notifications =
            PrayerNotificationBuilder.build(
              now: _now,
              location: location,
              settings: _settings,
              notificationSettings: _notifications,
              prayerTimesService: _prayerTimesService,
            );
        await _notificationService.schedulePrayerNotifications(
          notifications: notifications,
          sound: _notifications.sound,
        );
      } while (_syncPending);
    } catch (error) {
      debugPrint('Could not schedule prayer notifications: $error');
    } finally {
      _isSyncingNotifications = false;
    }
  }

  /// Pushes the coming week's prayer times to the Android home screen widget.
  Future<void> _pushHomeWidget() async {
    if (_disposed || !location.isResolved) return;
    try {
      final List<PrayerSchedule> days = <PrayerSchedule>[
        for (int i = 0; i < 7; i++)
          _prayerTimesService.scheduleFor(
            date: _now.add(Duration(days: i)),
            location: location,
            settings: _settings,
          ),
      ];
      await _homeWidgetService.updatePrayerTimes(
        locationName: location.name,
        days: days,
      );
    } catch (error) {
      debugPrint('Could not update the home screen widget: $error');
    }
  }

  Future<void> _prepareNotifications() async {
    try {
      await _notificationService.initialize();
      // The system permission dialog must only appear when the user asks for
      // it — on the intro's enable button — not at launch. Reminders default
      // to enabled, so first launches would otherwise prompt immediately.
      if (_notifications.enabled && _onboardingComplete) {
        _notificationsReady = await _notificationService.requestPermission();
        _exactAlarmsAllowed = await _notificationService
            .canScheduleExactNotifications();
      }
    } catch (error) {
      debugPrint('Notification setup failed: $error');
      _notificationsReady = false;
    }
    _notify();
  }

  /// The prayer schedule for an arbitrary date at the shown location, used
  /// to browse previous and future days from the home screen.
  PrayerSchedule scheduleForDate(DateTime date) => _prayerTimesService
      .scheduleFor(date: date, location: location, settings: _settings);

  PrayerDay _computeDay() => _prayerTimesService.dayFor(
    now: _now,
    location: location,
    settings: _settings,
  );

  void _startTicker() {
    if (_disposed) return;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime next = _clock();
      final bool dateChanged =
          next.year != _now.year ||
          next.month != _now.month ||
          next.day != _now.day;
      _now = next;
      if (dateChanged) {
        _day = null;
        unawaited(syncNotifications());
      }
      _notify();
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
