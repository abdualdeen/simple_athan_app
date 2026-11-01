import 'package:flutter/foundation.dart';

/// A place prayer times are calculated for.
@immutable
class AppLocation {
  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isResolved = false,
  });

  /// Used until a real location is known, or when permission is denied.
  static const AppLocation makkah = AppLocation(
    name: 'Makkah, Saudi Arabia',
    latitude: 21.4225,
    longitude: 39.8262,
  );

  final String name;
  final double latitude;
  final double longitude;

  /// Whether this is a real location (from the device or entered manually)
  /// rather than the fallback used before a location is known.
  final bool isResolved;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

  AppLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    bool? isResolved,
  }) {
    return AppLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
