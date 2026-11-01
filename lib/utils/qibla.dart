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
