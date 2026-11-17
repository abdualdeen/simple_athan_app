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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated decorative scene for the night sky theme: a glowing moon behind
/// the menu button, twinkling stars, and the occasional subtle shooting star.
class NightSkyScene extends StatefulWidget {
  const NightSkyScene({super.key});

  @override
  State<NightSkyScene> createState() => _NightSkySceneState();
}

class _NightSkySceneState extends State<NightSkyScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) => CustomPaint(
          size: Size.infinite,
          painter: _NightSkyScenePainter(
            palette: palette,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _NightSkyScenePainter extends CustomPainter {
  const _NightSkyScenePainter({required this.palette, required this.progress});

  final AppPalette palette;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintStars(canvas, size);
    _paintShootingStars(canvas, size);
    _paintMoon(canvas, size);
  }

  /// A field of stars, most of them small dots that twinkle, plus a few
  /// larger four-point sparkles.
  void _paintStars(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    for (int i = 0; i < 56; i++) {
      final double seed = i * 0.61803398875;
      final double x = ((seed * 7.13) % 1.0) * w;
      final double y = ((seed * 11.7) % 0.9) * h;
      final double radius = w * (0.0012 + ((seed * 3.3) % 1.0) * 0.0022);
      final double speed = 0.6 + ((seed * 5.1) % 1.0) * 2.4;
      final double phase = (seed * 13.1) % 1.0;
      final double twinkle =
          0.5 + 0.5 * math.sin(2 * math.pi * (progress * speed + phase));
      final Color color = i % 4 == 0 ? palette.accentSoft : Colors.white;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color.withValues(alpha: 0.2 + twinkle * 0.6),
      );
    }

    for (int i = 0; i < 6; i++) {
      final double seed = i * 0.7548776662;
      final double x = (0.08 + ((seed * 9.3) % 0.84)) * w;
      final double y = (0.08 + ((seed * 4.7) % 0.7)) * h;
      final double radius = w * (0.006 + ((seed * 6.7) % 1.0) * 0.005);
      final double speed = 0.4 + ((seed * 2.3) % 1.0) * 1.2;
      final double phase = (seed * 8.9) % 1.0;
      final double twinkle =
          0.5 + 0.5 * math.sin(2 * math.pi * (progress * speed + phase));
      _drawSparkle(
        canvas,
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withValues(alpha: 0.35 + twinkle * 0.6),
      );
    }
  }

  /// Two brief meteors per cycle, streaking down-left with a fading tail.
  void _paintShootingStars(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    const Offset direction = Offset(-0.87, 0.5);

    const List<(double, double, Offset, double)>
    meteors = <(double, double, Offset, double)>[
      // appearAt, flight duration, start position, travel length (of width).
      (0.30, 0.055, Offset(0.88, 0.06), 0.38),
      (0.72, 0.045, Offset(0.70, 0.02), 0.30),
    ];

    for (final (double appearAt, double duration, Offset start, double travel)
        in meteors) {
      final double local = (progress - appearAt) % 1.0;
      if (local >= duration) continue;
      final double t = local / duration;
      final double alpha = math.sin(t * math.pi);
      final Offset head = Offset(
        start.dx * w + direction.dx * travel * w * t,
        start.dy * h + direction.dy * travel * w * t,
      );

      for (int segment = 0; segment < 3; segment++) {
        final Offset from = head - direction * (w * 0.03 * segment);
        final Offset to = head - direction * (w * 0.03 * (segment + 1));
        canvas.drawLine(
          from,
          to,
          Paint()
            ..color = Colors.white.withValues(
              alpha: alpha * (0.5 - 0.15 * segment),
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.0022 * (1 - 0.25 * segment)
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(
        head,
        w * 0.0016,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * alpha),
      );
    }
  }

  /// Glowing full moon tucked behind the menu button, with soft craters.
  void _paintMoon(Canvas canvas, Size size) {
    final double radius = size.width * 0.08;
    final Offset center = Offset(size.width * 0.105, size.height * 0.20);
    final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);

    canvas.drawCircle(
      center,
      radius * 1.9,
      Paint()
        ..color = palette.accentSoft.withValues(alpha: 0.06 + 0.04 * pulse),
    );
    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()
        ..color = palette.accentSoft.withValues(alpha: 0.10 + 0.05 * pulse),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFFF3EEDF).withValues(alpha: 0.97),
    );

    final Paint craterPaint = Paint()
      ..color = const Color(0xFFD9D2BC).withValues(alpha: 0.8);
    canvas.drawCircle(
      center + Offset(-radius * 0.3, -radius * 0.25),
      radius * 0.18,
      craterPaint,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.25, radius * 0.1),
      radius * 0.13,
      craterPaint,
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.05, radius * 0.42),
      radius * 0.1,
      craterPaint,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.42, -radius * 0.3),
      radius * 0.08,
      craterPaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final double waist = radius * 0.18;
    final Path path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + waist,
        center.dy - waist,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + waist,
        center.dy + waist,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - waist,
        center.dy + waist,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - waist,
        center.dy - waist,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NightSkyScenePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
