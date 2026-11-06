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

import 'package:package_info_plus/package_info_plus.dart';

/// Static app metadata and links shown across the app.
abstract final class AppInfo {
  static const String appName = 'Simply Athan';
  static const String tagline = 'Prayer times & Qibla';
  static const String developer = 'Abdullah Aldeen';
  static const String githubUrl =
      'https://github.com/abdualdeen/simple_athan_app/';
  static const String privacyPolicyUrl =
      'https://github.com/abdualdeen/simple_athan_app/blob/master/PRIVACY.md';
  static const String licenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html';
  static const String licenseName = 'GNU General Public License v3.0';

  static String? _cachedVersion;

  /// The app version from the platform build metadata (pubspec `version`),
  /// e.g. `0.5.0-beta`.
  static Future<String> version() async {
    final String? cached = _cachedVersion;
    if (cached != null) return cached;
    final PackageInfo info = await PackageInfo.fromPlatform();
    return _cachedVersion = info.version;
  }
}
