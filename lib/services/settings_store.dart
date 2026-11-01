import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_location.dart';
import '../models/prayer_settings.dart';

abstract interface class SettingsStore {
  Future<PrayerSettings> loadSettings();
  Future<void> saveSettings(PrayerSettings settings);
  Future<AppLocation?> loadLocation();
  Future<void> saveLocation(AppLocation location);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  static const String _methodKey = 'prayer_method';
  static const String _madhabKey = 'asr_madhab';
  static const String _locationNameKey = 'location_name';
  static const String _locationLatitudeKey = 'location_latitude';
  static const String _locationLongitudeKey = 'location_longitude';

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
      isDeviceLocation: true,
    );
  }

  @override
  Future<void> saveLocation(AppLocation location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationNameKey, location.name);
    await prefs.setDouble(_locationLatitudeKey, location.latitude);
    await prefs.setDouble(_locationLongitudeKey, location.longitude);
  }
}
