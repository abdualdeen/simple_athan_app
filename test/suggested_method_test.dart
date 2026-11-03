import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/models/prayer_settings.dart';
import 'package:athan_app/utils/suggested_method.dart';

void main() {
  AppLocation locationAt({
    String? country,
    double latitude = 0,
    double longitude = 0,
  }) => AppLocation(
    name: 'test',
    latitude: latitude,
    longitude: longitude,
    countryCode: country,
    isResolved: true,
  );

  test('maps countries to their common calculation methods', () {
    expect(
      suggestedMethodFor(locationAt(country: 'US')),
      PrayerMethod.northAmerica,
    );
    expect(
      suggestedMethodFor(locationAt(country: 'CA')),
      PrayerMethod.northAmerica,
    );
    expect(
      suggestedMethodFor(locationAt(country: 'SA')),
      PrayerMethod.ummAlQura,
    );
    expect(suggestedMethodFor(locationAt(country: 'AE')), PrayerMethod.dubai);
    expect(suggestedMethodFor(locationAt(country: 'QA')), PrayerMethod.qatar);
    expect(suggestedMethodFor(locationAt(country: 'KW')), PrayerMethod.kuwait);
    expect(
      suggestedMethodFor(locationAt(country: 'EG')),
      PrayerMethod.egyptian,
    );
    expect(suggestedMethodFor(locationAt(country: 'PK')), PrayerMethod.karachi);
    expect(suggestedMethodFor(locationAt(country: 'IN')), PrayerMethod.karachi);
    expect(suggestedMethodFor(locationAt(country: 'TR')), PrayerMethod.turkiye);
    expect(suggestedMethodFor(locationAt(country: 'IR')), PrayerMethod.tehran);
    expect(
      suggestedMethodFor(locationAt(country: 'SG')),
      PrayerMethod.singapore,
    );
  });

  test('is case-insensitive for country codes', () {
    expect(
      suggestedMethodFor(locationAt(country: 'us')),
      PrayerMethod.northAmerica,
    );
  });

  test('keeps the default for countries without a common method', () {
    expect(
      suggestedMethodFor(locationAt(country: 'GB')),
      PrayerMethod.muslimWorldLeague,
    );
    expect(
      suggestedMethodFor(locationAt(country: 'FR')),
      PrayerMethod.muslimWorldLeague,
    );
  });

  test('falls back to coordinate regions when geocoding failed', () {
    // New York.
    expect(
      suggestedMethodFor(locationAt(latitude: 40.7128, longitude: -74.006)),
      PrayerMethod.northAmerica,
    );
    // Toronto.
    expect(
      suggestedMethodFor(locationAt(latitude: 43.6532, longitude: -79.3832)),
      PrayerMethod.northAmerica,
    );
    // Delhi.
    expect(
      suggestedMethodFor(locationAt(latitude: 28.6139, longitude: 77.209)),
      PrayerMethod.karachi,
    );
    // London.
    expect(
      suggestedMethodFor(locationAt(latitude: 51.5074, longitude: -0.1278)),
      PrayerMethod.muslimWorldLeague,
    );
    // Sydney.
    expect(
      suggestedMethodFor(locationAt(latitude: -33.8688, longitude: 151.2093)),
      PrayerMethod.muslimWorldLeague,
    );
  });
}
