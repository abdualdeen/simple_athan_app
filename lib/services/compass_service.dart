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

import 'package:compassx/compassx.dart';
import 'package:flutter/foundation.dart';

@immutable
class CompassReading {
  const CompassReading({
    required this.heading,
    this.accuracy,
    this.shouldCalibrate = false,
  });

  /// Heading relative to true north, in degrees.
  final double heading;

  /// Estimated error in degrees, when the platform provides it.
  final double? accuracy;

  /// Whether the platform thinks the compass needs calibration.
  final bool shouldCalibrate;
}

abstract interface class CompassService {
  Stream<CompassReading> headingStream();
}

/// Streams the device's true-north heading in degrees.
class DeviceCompassService implements CompassService {
  const DeviceCompassService();

  @override
  Stream<CompassReading> headingStream() {
    return CompassX.events.map(
      (CompassXEvent event) => CompassReading(
        heading: event.heading,
        accuracy: event.accuracy < 0 ? null : event.accuracy,
        shouldCalibrate: event.shouldCalibrate,
      ),
    );
  }
}
