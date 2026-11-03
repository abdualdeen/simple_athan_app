import 'package:geocoding/geocoding.dart';

import '../models/app_location.dart';
import 'place_names.dart';

abstract interface class LocationSearchService {
  Future<List<AppLocation>> search(String query);
}

/// Finds locations by place name, or accepts `latitude, longitude` input.
class GeocodingLocationSearchService implements LocationSearchService {
  const GeocodingLocationSearchService();

  static final RegExp _coordinatePattern = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*[, ]\s*(-?\d+(?:\.\d+)?)\s*$',
  );

  @override
  Future<List<AppLocation>> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return const <AppLocation>[];

    final AppLocation? coordinates = parseCoordinates(trimmed);
    if (coordinates != null) {
      final PlaceInfo info = await placeInfoFor(
        coordinates.latitude,
        coordinates.longitude,
      );
      return <AppLocation>[
        coordinates.copyWith(
          name: info.name ?? coordinates.name,
          countryCode: info.countryCode,
        ),
      ];
    }

    final List<Location> matches = await Geocoding().locationFromAddress(
      trimmed,
    );
    final List<AppLocation> results = <AppLocation>[];
    for (final Location match in matches.take(5)) {
      final PlaceInfo info = await placeInfoFor(
        match.latitude,
        match.longitude,
      );
      results.add(
        AppLocation(
          name: info.name ?? trimmed,
          latitude: match.latitude,
          longitude: match.longitude,
          countryCode: info.countryCode,
          isResolved: true,
        ),
      );
    }
    return results;
  }

  /// Parses `51.5074, -0.1278` or `51.5074 -0.1278`.
  static AppLocation? parseCoordinates(String input) {
    final RegExpMatch? match = _coordinatePattern.firstMatch(input);
    if (match == null) return null;

    final double? latitude = double.tryParse(match.group(1)!);
    final double? longitude = double.tryParse(match.group(2)!);
    if (latitude == null || longitude == null) return null;
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;

    return AppLocation(
      name: coordinateLabel(latitude, longitude),
      latitude: latitude,
      longitude: longitude,
      isResolved: true,
    );
  }
}
