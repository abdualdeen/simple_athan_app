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

import 'package:geocoding/geocoding.dart';

/// e.g. `51.507°, -0.128°`.
String coordinateLabel(double latitude, double longitude) =>
    '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';

/// Reverse-geocoded place information: a display name and the ISO country
/// code. Both are best-effort and `null` when the platform geocoder is
/// unavailable or has no result.
typedef PlaceInfo = ({String? name, String? countryCode});

/// Best-effort reverse geocoding used for display names and country lookup.
Future<PlaceInfo> placeInfoFor(double latitude, double longitude) async {
  try {
    final List<Placemark> placemarks = await Geocoding()
        .placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return (name: null, countryCode: null);
    final Placemark place = placemarks.first;
    return (name: formatPlacemark(place), countryCode: place.isoCountryCode);
  } catch (_) {
    return (name: null, countryCode: null);
  }
}

/// Best-effort reverse geocoding used for display names. Returns `null` when
/// the platform geocoder is unavailable or has no result.
Future<String?> placeNameFor(double latitude, double longitude) async =>
    (await placeInfoFor(latitude, longitude)).name;

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
