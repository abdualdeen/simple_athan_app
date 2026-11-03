import '../models/app_location.dart';
import '../models/prayer_settings.dart';

/// The calculation methods commonly used in each country (ISO 3166-1 alpha-2).
///
/// Countries without an entry keep the app default (Muslim World League).
const Map<String, PrayerMethod> _methodByCountry = <String, PrayerMethod>{
  // North America.
  'US': PrayerMethod.northAmerica,
  'CA': PrayerMethod.northAmerica,
  // Arabia.
  'SA': PrayerMethod.ummAlQura,
  'AE': PrayerMethod.dubai,
  'QA': PrayerMethod.qatar,
  'KW': PrayerMethod.kuwait,
  // Egypt and the Levant.
  'EG': PrayerMethod.egyptian,
  'JO': PrayerMethod.egyptian,
  'LB': PrayerMethod.egyptian,
  'SY': PrayerMethod.egyptian,
  'IQ': PrayerMethod.egyptian,
  'PS': PrayerMethod.egyptian,
  // South Asia.
  'PK': PrayerMethod.karachi,
  'IN': PrayerMethod.karachi,
  'BD': PrayerMethod.karachi,
  'AF': PrayerMethod.karachi,
  // Turkey and Iran.
  'TR': PrayerMethod.turkiye,
  'IR': PrayerMethod.tehran,
  // South-East Asia.
  'SG': PrayerMethod.singapore,
  'MY': PrayerMethod.singapore,
  'ID': PrayerMethod.singapore,
  'BN': PrayerMethod.singapore,
};

/// The calculation method commonly used at [location].
///
/// Uses the reverse-geocoded country when available, and falls back to coarse
/// coordinate regions when geocoding failed. Locations that cannot be
/// classified keep the app default.
PrayerMethod suggestedMethodFor(AppLocation location) {
  final String? country = location.countryCode?.toUpperCase();
  if (country != null) {
    return _methodByCountry[country] ?? PrayerMethod.muslimWorldLeague;
  }
  return _methodByRegion(location.latitude, location.longitude);
}

PrayerMethod _methodByRegion(double latitude, double longitude) {
  if (_isInNorthAmerica(latitude, longitude)) return PrayerMethod.northAmerica;
  if (_isInSouthAsia(latitude, longitude)) return PrayerMethod.karachi;
  return PrayerMethod.muslimWorldLeague;
}

bool _isInNorthAmerica(double latitude, double longitude) =>
    latitude >= 13 && latitude <= 74 && longitude >= -170 && longitude <= -50;

bool _isInSouthAsia(double latitude, double longitude) =>
    latitude >= 5 && latitude <= 37 && longitude >= 60 && longitude <= 95;
