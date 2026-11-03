import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      // Fall back to the last cached fix, which is accurate enough for prayer
      // times.
      position = await _lastKnownPosition();
    } on PlatformException catch (error) {
      debugPrint('Current position lookup failed: $error');
      position = await _lastKnownPosition();
    }

    if (position == null) {
      throw const LocationException(
        'Could not get a location fix. Check that location services are on '
        'and try again.',
      );
    }

    // Reverse geocoding only supplies a display name, so it must never block
    // the location itself. The platform geocoder can wait indefinitely when the
    // device has no geocoder backend or no network access, so fall back to
    // coordinates in that case.
    final String name =
        await placeNameFor(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5), onTimeout: () => null) ??
        coordinateLabel(position.latitude, position.longitude);

    return AppLocation(
      name: name,
      latitude: position.latitude,
      longitude: position.longitude,
      isResolved: true,
    );
  }

  /// Fetches a cached fix, bounded so a platform request that never answers
  /// cannot leave the app stuck on the fallback location.
  Future<Position?> _lastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 5),
      );
    } on TimeoutException {
      debugPrint('Last known position lookup timed out.');
    } catch (error) {
      debugPrint('Last known position lookup failed: $error');
    }
    return null;
  }
}
