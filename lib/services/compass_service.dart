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
