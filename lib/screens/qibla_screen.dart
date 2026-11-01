import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/prayer_times_controller.dart';
import '../models/app_location.dart';
import '../services/compass_service.dart';
import '../theme/app_theme.dart';
import '../utils/qibla.dart';

/// Compass that points towards the Kaaba for the current location.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({
    super.key,
    required this.controller,
    this.compassService = const DeviceCompassService(),
  });

  final PrayerTimesController controller;
  final CompassService compassService;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassReading>? _subscription;
  Timer? _sensorTimeout;
  double? _heading;
  bool _shouldCalibrate = false;
  bool _compassUnavailable = false;

  @override
  void initState() {
    super.initState();
    // The compass plugin only reports headings in portrait mode.
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _subscription = widget.compassService.headingStream().listen(
      (CompassReading reading) {
        if (!mounted) return;
        _sensorTimeout?.cancel();
        setState(() {
          _heading = reading.heading;
          _shouldCalibrate = reading.shouldCalibrate;
          _compassUnavailable = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _compassUnavailable = true);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _compassUnavailable = true);
      },
    );

    // Devices without a magnetometer may never emit a heading.
    _sensorTimeout = Timer(const Duration(seconds: 5), () {
      if (!mounted || _heading != null) return;
      setState(() => _compassUnavailable = true);
    });
  }

  @override
  void dispose() {
    _sensorTimeout?.cancel();
    _subscription?.cancel();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
        title: const Text(
          'Qibla',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (BuildContext context, Widget? _) {
          final AppLocation location = widget.controller.location;
          final double qibla = qiblaBearing(location);
          final double distanceKm = distanceToMakkahKm(location);
          final double? heading = _heading;
          final double? relative = heading == null
              ? null
              : (qibla - heading + 360) % 360;
          final bool aligned =
              relative != null && (relative <= 5 || relative >= 355);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: <Widget>[
              _LocationLine(location: location),
              const SizedBox(height: 20),
              Center(
                child: _CompassDial(
                  qibla: qibla,
                  heading: heading,
                  aligned: aligned,
                  distanceKm: distanceKm,
                ),
              ),
              const SizedBox(height: 24),
              _StatusCard(
                aligned: aligned,
                hasHeading: heading != null,
                unavailable: _compassUnavailable,
                shouldCalibrate: _shouldCalibrate,
                qibla: qibla,
              ),
              const SizedBox(height: 16),
              const _CalibrationNote(),
            ],
          );
        },
      ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.qibla,
    required this.heading,
    required this.aligned,
    required this.distanceKm,
  });

  final double qibla;
  final double? heading;
  final bool aligned;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final double rotation = heading == null ? 0 : -heading! * math.pi / 180;
    final TextStyle labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    );

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.rotate(
            angle: rotation,
            child: CustomPaint(
              size: const Size.square(280),
              painter: _CompassDialPainter(
                palette: palette,
                qibla: qibla,
                aligned: aligned,
                labelStyle: labelStyle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Icon(
              Icons.arrow_drop_down_rounded,
              size: 34,
              color: aligned ? palette.accent : palette.primary,
            ),
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: palette.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${qibla.round()}°',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                    height: 1.1,
                  ),
                ),
                Text(
                  cardinalDirection(qibla),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: palette.label,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${distanceKm.round()} km',
                  style: TextStyle(fontSize: 11, color: palette.inkMuted),
                ),
                Text(
                  'to Makkah',
                  style: TextStyle(fontSize: 10, color: palette.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter({
    required this.palette,
    required this.qibla,
    required this.aligned,
    required this.labelStyle,
  });

  final AppPalette palette;
  final double qibla;
  final bool aligned;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    final Paint ringPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, ringPaint);

    final Paint tickPaint = Paint()
      ..color = palette.inkMuted.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final double angle = i * 5 * math.pi / 180;
      final bool major = i % 9 == 0;
      final bool medium = i % 3 == 0;
      final double inner = radius - (major ? 18 : (medium ? 12 : 7));
      final Offset direction = Offset(math.sin(angle), -math.cos(angle));
      canvas.drawLine(
        center + direction * inner,
        center + direction * (radius - 4),
        tickPaint,
      );
    }

    const List<String> labels = <String>['N', 'E', 'S', 'W'];
    for (int i = 0; i < labels.length; i++) {
      final double angle = i * 90 * math.pi / 180;
      final Offset position =
          center + Offset(math.sin(angle), -math.cos(angle)) * (radius - 46);
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: labelStyle.copyWith(
            color: i == 0 ? palette.accent : palette.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final double qiblaAngle = qibla * math.pi / 180;
    final Offset marker =
        center +
        Offset(math.sin(qiblaAngle), -math.cos(qiblaAngle)) * (radius - 32);
    canvas.drawCircle(
      marker,
      aligned ? 18 : 16,
      Paint()..color = palette.accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: marker, width: 12, height: 12),
        const Radius.circular(2),
      ),
      Paint()..color = palette.primaryDeep,
    );
    canvas.drawRect(
      Rect.fromCenter(center: marker.translate(0, -2), width: 12, height: 3),
      Paint()..color = palette.accentSoft,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.qibla != qibla ||
      oldDelegate.aligned != aligned ||
      oldDelegate.palette != palette ||
      oldDelegate.labelStyle != labelStyle;
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.location});

  final AppLocation location;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: palette.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                location.name,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location.coordinatesLabel,
                style: TextStyle(fontSize: 12, color: palette.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.aligned,
    required this.hasHeading,
    required this.unavailable,
    required this.shouldCalibrate,
    required this.qibla,
  });

  final bool aligned;
  final bool hasHeading;
  final bool unavailable;
  final bool shouldCalibrate;
  final double qibla;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final String text;
    if (unavailable) {
      text = 'Compass unavailable. Face ${qibla.round()}° from north.';
    } else if (!hasHeading) {
      text = 'Waiting for the compass…';
    } else if (shouldCalibrate) {
      text = 'Compass needs calibration. Move your phone in a figure-eight.';
    } else if (aligned) {
      text = 'You are facing the Qibla.';
    } else {
      text = 'Turn your phone until the Kaaba marker is at the top.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aligned
            ? palette.primary.withValues(alpha: 0.1)
            : palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: aligned
              ? palette.primary.withValues(alpha: 0.3)
              : palette.primary.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            aligned
                ? Icons.check_circle_rounded
                : (shouldCalibrate
                      ? Icons.warning_amber_rounded
                      : Icons.explore_outlined),
            color: aligned
                ? palette.primary
                : (shouldCalibrate ? palette.accentDark : palette.inkMuted),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: aligned ? palette.ink : palette.inkMuted,
                height: 1.35,
                fontWeight: aligned ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationNote extends StatelessWidget {
  const _CalibrationNote();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 17, color: palette.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hold your phone flat and move it in a figure-eight to calibrate '
              'the compass. The Qibla direction is calculated for your saved '
              'location.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
