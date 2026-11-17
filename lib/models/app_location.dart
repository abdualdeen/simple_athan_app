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

import 'package:flutter/foundation.dart';

/// A place prayer times are calculated for.
@immutable
class AppLocation {
  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.countryCode,
    this.isResolved = false,
    this.fromDevice = false,
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

  /// ISO 3166-1 alpha-2 code of the country this location is in, when reverse
  /// geocoding could resolve it. Used to pick a calculation method.
  final String? countryCode;

  /// Whether this is a real location (from the device or entered manually)
  /// rather than the fallback used before a location is known.
  final bool isResolved;

  /// Whether this location was found by the device's location service rather
  /// than picked by hand. When automatic location is on, a refreshed position
  /// updates the slot that tracks the device instead of overwriting a place
  /// the user chose manually.
  final bool fromDevice;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

  AppLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? countryCode,
    bool? isResolved,
    bool? fromDevice,
  }) {
    return AppLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      countryCode: countryCode ?? this.countryCode,
      isResolved: isResolved ?? this.isResolved,
      fromDevice: fromDevice ?? this.fromDevice,
    );
  }
}
