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

    // Reverse geocoding only supplies a display name and country, so it must
    // never block the location itself. The platform geocoder can wait
    // indefinitely when the device has no geocoder backend or no network
    // access, so fall back to coordinates in that case.
    final PlaceInfo info =
        await placeInfoFor(position.latitude, position.longitude).timeout(
          const Duration(seconds: 5),
          onTimeout: () => (name: null, countryCode: null),
        );

    return AppLocation(
      name: info.name ?? coordinateLabel(position.latitude, position.longitude),
      latitude: position.latitude,
      longitude: position.longitude,
      countryCode: info.countryCode,
      isResolved: true,
      fromDevice: true,
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
