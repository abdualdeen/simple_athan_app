import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/services/location_search_service.dart';

void main() {
  test('parses comma and space separated coordinates', () {
    final AppLocation? comma = GeocodingLocationSearchService.parseCoordinates(
      '51.5074, -0.1278',
    );
    expect(comma, isNotNull);
    expect(comma!.latitude, 51.5074);
    expect(comma.longitude, -0.1278);
    expect(comma.isResolved, isTrue);

    final AppLocation? space = GeocodingLocationSearchService.parseCoordinates(
      '48.8566 2.3522',
    );
    expect(space?.latitude, 48.8566);
    expect(space?.longitude, 2.3522);
  });

  test('rejects place names and out-of-range coordinates', () {
    expect(GeocodingLocationSearchService.parseCoordinates('London'), isNull);
    expect(GeocodingLocationSearchService.parseCoordinates('91, 0'), isNull);
    expect(GeocodingLocationSearchService.parseCoordinates('0, 181'), isNull);
    expect(GeocodingLocationSearchService.parseCoordinates(''), isNull);
  });
}
