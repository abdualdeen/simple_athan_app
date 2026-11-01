import 'dart:async';

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
      position = await Geolocator.getLastKnownPosition();
    }

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
}
