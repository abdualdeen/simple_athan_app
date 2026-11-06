# Simply Athan

A simple, private, open-source prayer times and Qibla app for Android, built
with Flutter.

Simply Athan shows the daily prayer times for your location, reminds you with
an athan notification when each prayer is due, and points the way to the Qibla
with a compass. It has no accounts, no advertising, no analytics and no
trackers — everything it knows about you stays on your device. See
[PRIVACY.md](PRIVACY.md) for the full privacy policy.

## Features

- **Prayer times** — calculated on device with
  [adhan_dart](https://pub.dev/packages/adhan_dart), with a choice of
  calculation methods (Muslim World League, Moonsighting Committee, ISNA,
  Egyptian General Authority, Karachi, Umm al-Qura, Dubai, Qatar, Kuwait,
  Singapore, and more) and Standard or Hanafi Asr.
- **Athan reminders** — exact-scheduled notifications for each prayer, even
  after a device restart. Choose the system sound or a bundled athan
  (Makkah – Ali Mullah, Madina – Muhammad Qassas), and mute any prayers you
  don't want to hear.
- **Qibla compass** — the bearing to the Qibla from your current location.
- **Flexible locations** — use the device location automatically, or search
  for a place by name; up to two saved locations you can switch between.
- **Themes** — Emerald, Dark, Olive, Sakura and Night Sky.

## Getting started

You need a recent stable [Flutter SDK](https://docs.flutter.dev/get-started/install)
(the project targets Dart `^3.13.5`) with the Android toolchain installed —
run `flutter doctor` to check your setup. Android is the primary target
(minimum API level 24).

```sh
git clone https://github.com/abdualdeen/simple_athan_app.git
cd simple_athan_app
flutter pub get
flutter run
```

## Development

```sh
flutter analyze   # static analysis (flutter_lints)
flutter test      # unit and widget tests
```

Source files carry a GPL license header; `scripts/check_license_headers.sh`
verifies them and `scripts/add_license_headers.sh` adds missing ones.

## Building a release

```sh
flutter build appbundle --release   # Android App Bundle for Google Play
flutter build apk --release         # APK for sideloading / F-Droid style distribution
```

Release builds are signed with an upload keystore described by
`android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=path/to/upload-keystore.jks
```

Create the keystore with:

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

`key.properties` and any `*.jks`/`*.keystore` files are gitignored — never
commit them, and keep a backup of the keystore somewhere safe. Release builds
require `key.properties` to be present; without it, signing fails (for local
release testing you can temporarily switch `signingConfig` to the debug key in
`android/app/build.gradle.kts`). See the
[Flutter Android signing guide](https://docs.flutter.dev/deployment/android#signing-the-app)
for details.

Release builds enable R8 minification and resource shrinking. The notification
icon and bundled athan sounds are looked up by resource name at runtime, so
they are pinned in `android/app/src/main/res/raw/keep.xml` — if you add more
runtime-resolved resources, list them there.

## Project layout

```
lib/
  controllers/   app state (prayer times, theme)
  models/        prayers, settings, locations, sounds
  screens/       home, qibla, settings, onboarding, about
  services/      location, geocoding, notifications, compass, storage
  theme/         palettes and theming
  widgets/       shared UI components
android/         Android host project (manifest, icons, signing)
```

## License

Simply Athan is free software released under the
[GNU General Public License v3.0](LICENSE).
