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

import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../models/app_location.dart';

const List<String> _cardinals = <String>[
  'N',
  'NNE',
  'NE',
  'ENE',
  'E',
  'ESE',
  'SE',
  'SSE',
  'S',
  'SSW',
  'SW',
  'WSW',
  'W',
  'WNW',
  'NW',
  'NNW',
];

/// The Qibla direction in degrees clockwise from true north.
double qiblaBearing(AppLocation location) =>
    adhan.Qibla.qibla(adhan.Coordinates(location.latitude, location.longitude));

/// Great-circle distance to the Kaaba in kilometres.
double distanceToMakkahKm(AppLocation location) {
  const double earthRadiusKm = 6371.0088;
  const adhan.Coordinates makkah = adhan.Qibla.makkah;

  final double lat1 = _toRadians(location.latitude);
  final double lat2 = _toRadians(makkah.latitude);
  final double deltaLat = lat2 - lat1;
  final double deltaLng = _toRadians(makkah.longitude - location.longitude);

  final double a =
      math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLng / 2) *
          math.sin(deltaLng / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

/// e.g. `118.99` -> `ESE`.
String cardinalDirection(double degrees) {
  final int index = ((degrees % 360) / 22.5).round() % 16;
  return _cardinals[index];
}

double _toRadians(double degrees) => degrees * math.pi / 180;
