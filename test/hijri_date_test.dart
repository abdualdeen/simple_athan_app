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
