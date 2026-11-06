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

import 'package:athan_app/models/app_location.dart';
import 'package:athan_app/services/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns no locations when nothing is stored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();

    final SavedLocationState state = await store.loadLocations();

    expect(state.locations, isEmpty);
    expect(state.activeIndex, 0);
  });

  test('migrates the legacy single location on first load', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'location_name': 'London, United Kingdom',
      'location_latitude': 51.5074,
      'location_longitude': -0.1278,
    });
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();

    final SavedLocationState state = await store.loadLocations();

    expect(state.locations, hasLength(1));
    expect(state.locations.first.name, 'London, United Kingdom');
    expect(state.locations.first.isResolved, isTrue);
    expect(state.activeIndex, 0);
  });

  test('saves and reloads two locations with the active index', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();
    const AppLocation london = AppLocation(
      name: 'London, United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      isResolved: true,
    );
    const AppLocation paris = AppLocation(
      name: 'Paris, France',
      latitude: 48.8566,
      longitude: 2.3522,
      isResolved: true,
    );

    await store.saveLocations((
      locations: <AppLocation>[london, paris],
      activeIndex: 1,
    ));
    final SavedLocationState state = await store.loadLocations();

    expect(state.locations, hasLength(2));
    expect(state.locations[0].name, 'London, United Kingdom');
    expect(state.locations[1].name, 'Paris, France');
    expect(state.activeIndex, 1);
  });

  test('saving a single location clears the second slot', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();
    const AppLocation london = AppLocation(
      name: 'London, United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      isResolved: true,
    );
    const AppLocation paris = AppLocation(
      name: 'Paris, France',
      latitude: 48.8566,
      longitude: 2.3522,
      isResolved: true,
    );
    await store.saveLocations((
      locations: <AppLocation>[london, paris],
      activeIndex: 1,
    ));

    await store.saveLocations((
      locations: <AppLocation>[london],
      activeIndex: 0,
    ));
    final SavedLocationState state = await store.loadLocations();

    expect(state.locations, hasLength(1));
    expect(state.locations.first.name, 'London, United Kingdom');
    expect(state.activeIndex, 0);
  });

  test('the intro flag defaults to false and round-trips', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();

    expect(await store.loadOnboardingComplete(), isFalse);

    await store.saveOnboardingComplete(true);

    expect(await store.loadOnboardingComplete(), isTrue);
  });

  test(
    'the automatic location flag defaults to true and round-trips',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesSettingsStore store =
          SharedPreferencesSettingsStore();

      expect(await store.loadAutomaticLocation(), isTrue);

      await store.saveAutomaticLocation(false);
      expect(await store.loadAutomaticLocation(), isFalse);

      await store.saveAutomaticLocation(true);
      expect(await store.loadAutomaticLocation(), isTrue);
    },
  );

  test('persists which location came from the device', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();
    const AppLocation london = AppLocation(
      name: 'London, United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      isResolved: true,
      fromDevice: true,
    );
    const AppLocation paris = AppLocation(
      name: 'Paris, France',
      latitude: 48.8566,
      longitude: 2.3522,
      isResolved: true,
    );

    await store.saveLocations((
      locations: <AppLocation>[london, paris],
      activeIndex: 1,
    ));
    final SavedLocationState state = await store.loadLocations();

    expect(state.locations[0].fromDevice, isTrue);
    expect(state.locations[1].fromDevice, isFalse);
  });

  test('clamps an out-of-range active index', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'saved_location_0_name': 'London, United Kingdom',
      'saved_location_0_lat': 51.5074,
      'saved_location_0_lng': -0.1278,
      'active_location_index': 5,
    });
    final SharedPreferencesSettingsStore store =
        SharedPreferencesSettingsStore();

    final SavedLocationState state = await store.loadLocations();

    expect(state.activeIndex, 0);
  });
}
