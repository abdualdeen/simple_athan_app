import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_location.dart';
import '../models/athan_sound.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../theme/app_theme.dart';

/// The saved locations and the index of the active one.
typedef SavedLocationState = ({List<AppLocation> locations, int activeIndex});

abstract interface class SettingsStore {
  Future<PrayerSettings> loadSettings();
  Future<void> saveSettings(PrayerSettings settings);

  /// Whether a calculation method has been saved before, either by the user
  /// or by the first-launch region suggestion.
  Future<bool> hasSavedMethod();

  /// The saved locations (at most two) and which one is active.
  Future<SavedLocationState> loadLocations();
  Future<void> saveLocations(SavedLocationState state);
  Future<NotificationSettings> loadNotificationSettings();
  Future<void> saveNotificationSettings(NotificationSettings settings);
  Future<AppThemeChoice> loadTheme();
  Future<void> saveTheme(AppThemeChoice choice);

  /// Whether the first-launch intro has been finished.
  Future<bool> loadOnboardingComplete();
  Future<void> saveOnboardingComplete(bool complete);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  static const String _methodKey = 'prayer_method';
  static const String _madhabKey = 'asr_madhab';
  static const String _locationNameKey = 'location_name';
  static const String _locationLatitudeKey = 'location_latitude';
  static const String _locationLongitudeKey = 'location_longitude';
  static const String _activeLocationIndexKey = 'active_location_index';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _mutedPrayersKey = 'muted_prayers';
  static const String _notificationSoundKey = 'notification_sound';
  static const String _themeKey = 'app_theme';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  @override
  Future<PrayerSettings> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return PrayerSettings(
      method: PrayerMethod.fromName(prefs.getString(_methodKey)),
      madhab: AsrMadhab.fromName(prefs.getString(_madhabKey)),
    );
  }

  @override
  Future<void> saveSettings(PrayerSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_methodKey, settings.method.name);
    await prefs.setString(_madhabKey, settings.madhab.name);
  }

  @override
  Future<bool> hasSavedMethod() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_methodKey) != null;
  }

  @override
  Future<SavedLocationState> loadLocations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<AppLocation> locations = <AppLocation?>[
      _readSavedSlot(prefs, 0),
      _readSavedSlot(prefs, 1),
    ].whereType<AppLocation>().toList();

    if (locations.isEmpty) {
      // Installs from before multiple locations existed stored a single
      // location under the legacy keys.
      final AppLocation? legacy = _readLegacyLocation(prefs);
      if (legacy == null) return (locations: locations, activeIndex: 0);
      return (locations: <AppLocation>[legacy], activeIndex: 0);
    }

    final int index = prefs.getInt(_activeLocationIndexKey) ?? 0;
    return (
      locations: locations,
      activeIndex: index.clamp(0, locations.length - 1),
    );
  }

  AppLocation? _readSavedSlot(SharedPreferences prefs, int slot) {
    final String? name = prefs.getString('saved_location_${slot}_name');
    final double? latitude = prefs.getDouble('saved_location_${slot}_lat');
    final double? longitude = prefs.getDouble('saved_location_${slot}_lng');
    if (name == null || latitude == null || longitude == null) return null;
    return AppLocation(
      name: name,
      latitude: latitude,
      longitude: longitude,
      isResolved: true,
    );
  }

  AppLocation? _readLegacyLocation(SharedPreferences prefs) {
    final String? name = prefs.getString(_locationNameKey);
    final double? latitude = prefs.getDouble(_locationLatitudeKey);
    final double? longitude = prefs.getDouble(_locationLongitudeKey);
    if (name == null || latitude == null || longitude == null) return null;
    return AppLocation(
      name: name,
      latitude: latitude,
      longitude: longitude,
      isResolved: true,
    );
  }

  @override
  Future<void> saveLocations(SavedLocationState state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int slot = 0; slot < 2; slot++) {
      final String prefix = 'saved_location_${slot}_';
      if (slot < state.locations.length) {
        final AppLocation location = state.locations[slot];
        await prefs.setString('${prefix}name', location.name);
        await prefs.setDouble('${prefix}lat', location.latitude);
        await prefs.setDouble('${prefix}lng', location.longitude);
      } else {
        await prefs.remove('${prefix}name');
        await prefs.remove('${prefix}lat');
        await prefs.remove('${prefix}lng');
      }
    }
    await prefs.setInt(_activeLocationIndexKey, state.activeIndex);
  }

  @override
  Future<NotificationSettings> loadNotificationSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> mutedNames =
        prefs.getStringList(_mutedPrayersKey) ?? const <String>[];
    return NotificationSettings(
      enabled: prefs.getBool(_notificationsEnabledKey) ?? true,
      muted: mutedNames.map(PrayerId.fromName).whereType<PrayerId>().toSet(),
      sound: AthanSound.fromName(prefs.getString(_notificationSoundKey)),
    );
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, settings.enabled);
    await prefs.setStringList(
      _mutedPrayersKey,
      settings.muted.map((PrayerId id) => id.name).toList(),
    );
    await prefs.setString(_notificationSoundKey, settings.sound.name);
  }

  @override
  Future<AppThemeChoice> loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AppThemeChoice.fromName(prefs.getString(_themeKey));
  }

  @override
  Future<void> saveTheme(AppThemeChoice choice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, choice.name);
  }

  @override
  Future<bool> loadOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  @override
  Future<void> saveOnboardingComplete(bool complete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, complete);
  }
}
