import 'package:athan_app/utils/location_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('abbreviates the state and country of a full placemark name', () {
    expect(
      abbreviateLocationName('Portland, Oregon, United States'),
      'Portland, OR, US',
    );
    expect(
      abbreviateLocationName('Columbus, Ohio, United States'),
      'Columbus, OH, US',
    );
  });

  test('abbreviates Canadian provinces and Australian states', () {
    expect(
      abbreviateLocationName('Toronto, Ontario, Canada'),
      'Toronto, ON, CA',
    );
    expect(
      abbreviateLocationName('Melbourne, Victoria, Australia'),
      'Melbourne, VIC, AU',
    );
  });

  test('abbreviates a country-only suffix', () {
    expect(abbreviateLocationName('London, United Kingdom'), 'London, UK');
    expect(abbreviateLocationName('Makkah, Saudi Arabia'), 'Makkah, SA');
  });

  test('handles a two-part name that ends in a state', () {
    expect(abbreviateLocationName('Portland, Oregon'), 'Portland, OR');
  });

  test('accepts alternate country spellings', () {
    expect(
      abbreviateLocationName('Houston, Texas, United States of America'),
      'Houston, TX, US',
    );
    expect(abbreviateLocationName('Dubai, United Arab Emirates'), 'Dubai, AE');
  });

  test('keeps regions without standard abbreviations', () {
    expect(
      abbreviateLocationName('Paris, Île-de-France, France'),
      'Paris, Île-de-France, FR',
    );
    expect(
      abbreviateLocationName('Manchester, England, United Kingdom'),
      'Manchester, England, UK',
    );
  });

  test('keeps a place name that matches a state of another country', () {
    expect(abbreviateLocationName('Victoria, Seychelles'), 'Victoria, SC');
    expect(abbreviateLocationName('Tbilisi, Georgia'), 'Tbilisi, GE');
  });

  test('leaves single-part and coordinate names alone', () {
    expect(abbreviateLocationName('Singapore'), 'Singapore');
    expect(abbreviateLocationName('Makkah'), 'Makkah');
    expect(abbreviateLocationName('51.507°, -0.128°'), '51.507°, -0.128°');
  });

  test('leaves already abbreviated names alone', () {
    expect(abbreviateLocationName('Portland, OR, US'), 'Portland, OR, US');
  });

  test('is tolerant of extra spaces around segments', () {
    expect(
      abbreviateLocationName('Columbus,  Ohio , United States'),
      'Columbus, OH, US',
    );
  });
}
