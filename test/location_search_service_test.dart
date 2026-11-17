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
