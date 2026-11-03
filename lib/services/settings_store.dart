import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_location.dart';
import '../models/athan_sound.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../theme/app_theme.dart';

abstract interface class SettingsStore {
  Future<PrayerSettings> loadSettings();
  Future<void> saveSettings(PrayerSettings settings);
  Future<AppLocation?> loadLocation();
  Future<void> saveLocation(AppLocation location);
  Future<NotificationSettings> loadNotificationSettings();
  Future<void> saveNotificationSettings(NotificationSettings settings);
  Future<AppThemeChoice> loadTheme();
  Future<void> saveTheme(AppThemeChoice choice);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  static const String _methodKey = 'prayer_method';
  static const String _madhabKey = 'asr_madhab';
  static const String _locationNameKey = 'location_name';
  static const String _locationLatitudeKey = 'location_latitude';
  static const String _locationLongitudeKey = 'location_longitude';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _mutedPrayersKey = 'muted_prayers';
  static const String _notificationSoundKey = 'notification_sound';
  static const String _themeKey = 'app_theme';

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
  Future<AppLocation?> loadLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
  Future<void> saveLocation(AppLocation location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationNameKey, location.name);
    await prefs.setDouble(_locationLatitudeKey, location.latitude);
    await prefs.setDouble(_locationLongitudeKey, location.longitude);
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
}
