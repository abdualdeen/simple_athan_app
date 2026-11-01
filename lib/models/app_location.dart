import 'package:flutter/foundation.dart';

/// A place prayer times are calculated for.
@immutable
class AppLocation {
  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isDeviceLocation = false,
  });

  /// Used until the device location is known, or when permission is denied.
  static const AppLocation makkah = AppLocation(
    name: 'Makkah, Saudi Arabia',
    latitude: 21.4225,
    longitude: 39.8262,
  );

  final String name;
  final double latitude;
  final double longitude;

  /// Whether this location came from the device's location services.
  final bool isDeviceLocation;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

  AppLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    bool? isDeviceLocation,
  }) {
    return AppLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDeviceLocation: isDeviceLocation ?? this.isDeviceLocation,
    );
  }
}
