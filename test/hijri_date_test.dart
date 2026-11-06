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

import 'package:athan_app/utils/hijri_date.dart';

void main() {
  test('converts known Gregorian dates to the Hijri calendar', () {
    expect(
      HijriDate.fromDateTime(DateTime(2024, 3, 11)).formatted,
      '1 Ramadan 1445 AH',
    );
    expect(
      HijriDate.fromDateTime(DateTime(2000, 1, 1)).formatted,
      '24 Ramadan 1420 AH',
    );
  });
}
