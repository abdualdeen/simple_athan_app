import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/app_location.dart';
import 'place_names.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class LocationService {
  Future<AppLocation> currentLocation();
}

/// Resolves the device's position and a human-readable place name.
class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  @override
  Future<AppLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Location services are turned off. Enable them in your device settings.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission was denied. Prayer times need your location.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is blocked. Enable it for Athan in your device '
        'settings.',
      );
    }

    // A recent cached fix is instant and accurate enough for prayer times.
    Position? position = await _recentLastKnownPosition();

    // Fall back from balanced accuracy to low power, then to any cached fix.
    position ??= await _tryCurrentPosition(
      LocationAccuracy.medium,
      const Duration(seconds: 30),
    );
    position ??= await _tryCurrentPosition(
      LocationAccuracy.low,
      const Duration(seconds: 15),
    );
    position ??= await _lastKnownPosition();

    if (position == null) {
      throw const LocationException(
        'Could not get a location fix. Check that location services are on '
        'and try again.',
      );
    }

    final String name =
        await placeNameFor(position.latitude, position.longitude) ??
        coordinateLabel(position.latitude, position.longitude);

    return AppLocation(
      name: name,
      latitude: position.latitude,
      longitude: position.longitude,
      isResolved: true,
    );
  }

  Future<Position?> _tryCurrentPosition(
    LocationAccuracy accuracy,
    Duration timeLimit,
  ) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _settings(accuracy, timeLimit),
      );
    } on LocationServiceDisabledException {
      throw const LocationException(
        'Location services are turned off. Enable them in your device settings.',
      );
    } on PermissionDeniedException {
      throw const LocationException(
        'Location permission was denied. Prayer times need your location.',
      );
    } on TimeoutException {
      return null;
    } catch (error) {
      debugPrint('Location lookup ($accuracy) failed: $error');
      return null;
    }
  }

  /// Uses the platform LocationManager on Android. Some devices ship with a
  /// modified Google Play Services where the fused provider never responds.
  LocationSettings _settings(LocationAccuracy accuracy, Duration timeLimit) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
        forceLocationManager: true,
      );
    }
    return LocationSettings(accuracy: accuracy, timeLimit: timeLimit);
  }

  Future<Position?> _recentLastKnownPosition() async {
    final Position? position = await _lastKnownPosition();
    if (position == null) return null;
    final Duration age = DateTime.now().difference(position.timestamp);
    return age <= const Duration(minutes: 10) ? position : null;
  }

  Future<Position?> _lastKnownPosition() async {
    try {
      // Some devices with a modified Play Services never answer this call.
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      return null;
    }
  }
}
