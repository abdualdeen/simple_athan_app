import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/utils/qibla.dart';

const AppLocation _london = AppLocation(
  name: 'London',
  latitude: 51.5074,
  longitude: -0.1278,
);

void main() {
  test('computes the qibla bearing for known cities', () {
    const AppLocation newYork = AppLocation(
      name: 'New York',
      latitude: 40.7128,
      longitude: -74.0060,
    );

    expect(qiblaBearing(_london), closeTo(118.99, 0.5));
    expect(qiblaBearing(newYork), closeTo(58.48, 0.5));
  });

  test('computes the distance to Makkah', () {
    expect(distanceToMakkahKm(_london), closeTo(4793.8, 30));
    expect(distanceToMakkahKm(AppLocation.makkah), closeTo(0, 1));
  });

  test('maps bearings to cardinal directions', () {
    expect(cardinalDirection(0), 'N');
    expect(cardinalDirection(45), 'NE');
    expect(cardinalDirection(90), 'E');
    expect(cardinalDirection(180), 'S');
    expect(cardinalDirection(270), 'W');
    expect(cardinalDirection(359), 'N');
  });
}
