import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_location.dart';
import '../models/prayer_schedule.dart';
import '../models/prayer_settings.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
import '../services/settings_store.dart';

/// Owns the app's location, calculation settings, and the current prayer day.
class PrayerTimesController extends ChangeNotifier {
  PrayerTimesController({
    required LocationService locationService,
    required SettingsStore settingsStore,
    PrayerTimesService prayerTimesService = const PrayerTimesService(),
    DateTime Function()? clock,
  }) : this._(
         locationService,
         settingsStore,
         prayerTimesService,
         clock ?? DateTime.now,
       );

  PrayerTimesController._(
    this._locationService,
    this._settingsStore,
    this._prayerTimesService,
    this._clock,
  ) : _now = _clock();

  final LocationService _locationService;
  final SettingsStore _settingsStore;
  final PrayerTimesService _prayerTimesService;
  final DateTime Function() _clock;

  AppLocation _location = AppLocation.makkah;
  PrayerSettings _settings = const PrayerSettings();
  PrayerDay? _day;
  bool _isInitializing = true;
  bool _isLocating = false;
  String? _locationError;
  Timer? _ticker;
  DateTime _now;
  bool _disposed = false;

  DateTime get now => _now;
  AppLocation get location => _location;
  PrayerSettings get settings => _settings;
  PrayerDay get day => _day ??= _computeDay();
  bool get isInitializing => _isInitializing;
  bool get isLocating => _isLocating;
  String? get locationError => _locationError;

  /// Loads saved settings and location, then asks the device for a fresh
  /// position when nothing has been saved yet.
  Future<void> initialize() async {
    try {
      _settings = await _settingsStore.loadSettings();
      final AppLocation? savedLocation = await _settingsStore.loadLocation();
      if (savedLocation != null) _location = savedLocation;
      _isInitializing = false;
      _day = null;
      _notify();
      _startTicker();
      if (savedLocation == null) await refreshLocation();
    } catch (error) {
      debugPrint('Failed to load saved settings: $error');
      _isInitializing = false;
      _notify();
      _startTicker();
      await refreshLocation();
    }
  }

  Future<void> refreshLocation() async {
    if (_isLocating) return;
    _isLocating = true;
    _locationError = null;
    _notify();

    try {
      final AppLocation location = await _locationService.currentLocation();
      _location = location;
      _day = null;
      await _settingsStore.saveLocation(location);
    } on LocationException catch (error) {
      _locationError = error.message;
    } catch (error) {
      debugPrint('Location lookup failed: $error');
      _locationError = 'Could not determine your location. Please try again.';
    } finally {
      _isLocating = false;
      _notify();
    }
  }

  Future<void> updateSettings(PrayerSettings settings) async {
    _settings = settings;
    _day = null;
    _notify();
    await _settingsStore.saveSettings(settings);
  }

  PrayerDay _computeDay() => _prayerTimesService.dayFor(
    now: _now,
    location: _location,
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
      if (dateChanged) _day = null;
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
