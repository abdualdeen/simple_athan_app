import 'package:geocoding/geocoding.dart';

/// e.g. `51.507°, -0.128°`.
String coordinateLabel(double latitude, double longitude) =>
    '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

/// Best-effort reverse geocoding used for display names. Returns `null` when
/// the platform geocoder is unavailable or has no result.
Future<String?> placeNameFor(double latitude, double longitude) async {
  try {
    final List<Placemark> placemarks = await Geocoding()
        .placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;
    return formatPlacemark(placemarks.first);
  } catch (_) {
    return null;
  }
}

/// Builds `city, state, country` from a placemark, skipping repeated parts.
///
/// For example:
/// - `Portland, Oregon, United States`
/// - `Paris, Île-de-France, France`
/// - `Singapore` (city, state and country are the same)
String? formatPlacemark(Placemark place) {
  final List<String> parts = <String>[];

  void add(String? value) {
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    final String lower = trimmed.toLowerCase();
    if (parts.any((String part) => part.toLowerCase() == lower)) return;
    parts.add(trimmed);
  }

  final String? city = _firstNonEmpty(<String?>[
    place.locality,
    place.subLocality,
    place.subAdministrativeArea,
    place.administrativeArea,
  ]);
  final String? state = _firstNonEmpty(<String?>[
    place.administrativeArea,
    place.subAdministrativeArea,
  ]);
  final String? country = place.country;

  add(city);
  add(state);
  add(country);

  return parts.isEmpty ? null : parts.join(', ');
}

String? _firstNonEmpty(List<String?> values) {
  for (final String? value in values) {
    final String? trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}
