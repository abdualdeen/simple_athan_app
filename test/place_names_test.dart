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
import 'package:geocoding/geocoding.dart';

import 'package:athan_app/services/place_names.dart';

void main() {
  test('includes city, state and country when they differ', () {
    expect(
      formatPlacemark(
        const Placemark(
          locality: 'Portland',
          administrativeArea: 'Oregon',
          country: 'United States',
        ),
      ),
      'Portland, Oregon, United States',
    );

    expect(
      formatPlacemark(
        const Placemark(
          locality: 'Paris',
          administrativeArea: 'Île-de-France',
          country: 'France',
        ),
      ),
      'Paris, Île-de-France, France',
    );

    expect(
      formatPlacemark(
        const Placemark(
          locality: 'London',
          administrativeArea: 'England',
          country: 'United Kingdom',
        ),
      ),
      'London, England, United Kingdom',
    );
  });

  test('does not repeat the same part', () {
    expect(
      formatPlacemark(
        const Placemark(
          locality: 'Singapore',
          administrativeArea: 'Singapore',
          country: 'Singapore',
        ),
      ),
      'Singapore',
    );

    expect(
      formatPlacemark(const Placemark(locality: 'Paris', country: 'France')),
      'Paris, France',
    );
  });

  test('falls back to the county when there is no city', () {
    expect(
      formatPlacemark(
        const Placemark(
          subAdministrativeArea: 'Multnomah County',
          administrativeArea: 'Oregon',
          country: 'United States',
        ),
      ),
      'Multnomah County, Oregon, United States',
    );
  });

  test('returns null when there is nothing to show', () {
    expect(formatPlacemark(const Placemark()), isNull);
  });
}
