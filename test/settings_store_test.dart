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
