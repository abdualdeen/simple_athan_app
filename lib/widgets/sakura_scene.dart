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

/// Animated decorative scene for the sakura theme: blossom branches reaching
/// in from the right, a crescent moon behind the menu button, and petals
/// drifting down.
class SakuraScene extends StatefulWidget {
  const SakuraScene({super.key});

  @override
  State<SakuraScene> createState() => _SakuraSceneState();
}

class _SakuraSceneState extends State<SakuraScene>
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
          painter: _SakuraScenePainter(
            palette: palette,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _SakuraScenePainter extends CustomPainter {
  const _SakuraScenePainter({required this.palette, required this.progress});

  final AppPalette palette;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintMoon(canvas, size);
    _paintTree(canvas, size);
    _paintPetals(canvas, size);
  }

  /// Crescent moon tucked behind the menu button in the top-left corner.
  void _paintMoon(Canvas canvas, Size size) {
    final double radius = size.width * 0.085;
    final Offset center = Offset(size.width * 0.105, size.height * 0.20);

    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()..color = palette.accentSoft.withValues(alpha: 0.10),
    );

    final Path full = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final Path bite = Path()
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(radius * 0.5, -radius * 0.22),
          radius: radius * 0.82,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, bite),
      Paint()..color = palette.accentSoft.withValues(alpha: 0.95),
    );
  }

  /// Sakura branches reaching in from the right edge, decorated with
  /// five-petal flowers and buds.
  void _paintTree(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Color bark = palette.primaryDeep.withValues(alpha: 0.9);
    final Color blossomLight = Color.lerp(
      palette.primarySoft,
      Colors.white,
      0.45,
    )!;
    final Color blossomMid = palette.primarySoft;
    final Color blossomDeep = palette.primary;

    // Main branches entering from the right edge, tapering as they reach in.
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.34),
      Offset(w * 0.78, h * 0.30),
      Offset(w * 0.52, h * 0.20),
      w * 0.020,
      w * 0.006,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.52),
      Offset(w * 0.82, h * 0.48),
      Offset(w * 0.63, h * 0.38),
      w * 0.016,
      w * 0.005,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.16),
      Offset(w * 0.86, h * 0.15),
      Offset(w * 0.73, h * 0.10),
      w * 0.013,
      w * 0.004,
      bark,
    );
    // Twigs branching off the mains.
    _drawBranch(
      canvas,
      Offset(w * 0.674, h * 0.255),
      Offset(w * 0.63, h * 0.21),
      Offset(w * 0.60, h * 0.15),
      w * 0.007,
      w * 0.003,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 0.784, h * 0.45),
      Offset(w * 0.77, h * 0.40),
      Offset(w * 0.745, h * 0.345),
      w * 0.006,
      w * 0.003,
      bark,
    );

    // Flowers clustered along the branches.
    final List<(Offset, double, Color, double)> flowers =
        <(Offset, double, Color, double)>[
          (Offset(w * 0.52, h * 0.19), w * 0.030, blossomMid, 0.3),
          (Offset(w * 0.598, h * 0.215), w * 0.026, blossomLight, 1.1),
          (Offset(w * 0.60, h * 0.14), w * 0.024, blossomLight, 2.2),
          (Offset(w * 0.674, h * 0.24), w * 0.026, blossomMid, 0.6),
          (Offset(w * 0.725, h * 0.255), w * 0.028, blossomLight, 1.9),
          (Offset(w * 0.73, h * 0.095), w * 0.024, blossomMid, 0.2),
          (Offset(w * 0.839, h * 0.12), w * 0.024, blossomLight, 1.4),
          (Offset(w * 0.874, h * 0.30), w * 0.028, blossomMid, 2.6),
          (Offset(w * 0.63, h * 0.375), w * 0.030, blossomLight, 0.9),
          (Offset(w * 0.706, h * 0.41), w * 0.024, blossomDeep, 1.7),
          (Offset(w * 0.745, h * 0.34), w * 0.024, blossomMid, 0.4),
          (Offset(w * 0.8225, h * 0.46), w * 0.024, blossomLight, 2.1),
          (Offset(w * 0.93, h * 0.30), w * 0.026, blossomMid, 1.2),
          (Offset(w * 0.965, h * 0.20), w * 0.024, blossomLight, 0.7),
        ];
    for (final (Offset center, double radius, Color color, double rotation)
        in flowers) {
      _drawFlower(canvas, center, radius, color, rotation: rotation);
    }

    // Buds near the branch tips.
    _drawBud(
      canvas,
      Offset(w * 0.545, h * 0.215),
      w * 0.016,
      -0.5,
      blossomLight,
      bark,
    );
    _drawBud(
      canvas,
      Offset(w * 0.655, h * 0.40),
      w * 0.015,
      -1.1,
      blossomMid,
      bark,
    );
    _drawBud(
      canvas,
      Offset(w * 0.755, h * 0.115),
      w * 0.014,
      -0.4,
      blossomLight,
      bark,
    );
  }

  /// Draws a tapering branch as a quadratic curve sampled into segments with
  /// shrinking stroke widths.
  void _drawBranch(
    Canvas canvas,
    Offset start,
    Offset bend,
    Offset end,
    double startWidth,
    double endWidth,
    Color color,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Offset previous = start;
    const int segments = 8;
    for (int i = 1; i <= segments; i++) {
      final double t = i / segments;
      final double u = 1 - t;
      final Offset point = Offset(
        u * u * start.dx + 2 * u * t * bend.dx + t * t * end.dx,
        u * u * start.dy + 2 * u * t * bend.dy + t * t * end.dy,
      );
      canvas.drawLine(
        previous,
        point,
        paint..strokeWidth = startWidth + (endWidth - startWidth) * t,
      );
      previous = point;
    }
  }

  /// Flat five-petal blossom with a white centre and stamen dots.
  void _drawFlower(
    Canvas canvas,
    Offset center,
    double radius,
    Color petalColor, {
    double rotation = 0,
  }) {
    for (int i = 0; i < 5; i++) {
      final double angle = rotation + i * 2 * math.pi / 5 - math.pi / 2;
      final Offset offset =
          Offset(math.cos(angle), math.sin(angle)) * radius * 0.62;
      canvas.drawCircle(
        center + offset,
        radius * 0.52,
        Paint()..color = petalColor,
      );
    }
    canvas.drawCircle(
      center,
      radius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    final Paint stamenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9);
    for (int i = 0; i < 5; i++) {
      final double angle = rotation + i * 2 * math.pi / 5 + math.pi / 5;
      final Offset offset =
          Offset(math.cos(angle), math.sin(angle)) * radius * 0.46;
      canvas.drawCircle(center + offset, radius * 0.07, stamenPaint);
    }
  }

  /// Two-tone bud: pink tip wrapped in a dark calyx cup.
  void _drawBud(
    Canvas canvas,
    Offset center,
    double size,
    double angle,
    Color petalColor,
    Color calyxColor,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final Path bud = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size * 0.9, -size * 0.35, size * 0.55, size * 0.4)
      ..quadraticBezierTo(0, size * 0.75, -size * 0.55, size * 0.4)
      ..quadraticBezierTo(-size * 0.9, -size * 0.35, 0, -size)
      ..close();
    canvas.drawPath(bud, Paint()..color = petalColor);
    final Path calyx = Path()
      ..moveTo(-size * 0.62, size * 0.18)
      ..quadraticBezierTo(-size * 0.5, size * 0.85, 0, size * 0.9)
      ..quadraticBezierTo(size * 0.5, size * 0.85, size * 0.62, size * 0.18)
      ..quadraticBezierTo(0, size * 0.45, -size * 0.62, size * 0.18)
      ..close();
    canvas.drawPath(calyx, Paint()..color = calyxColor);
    canvas.restore();
  }

  /// Petals drifting down with a gentle sway and spin.
  void _paintPetals(Canvas canvas, Size size) {
    const int petalCount = 14;
    final double w = size.width;
    final double h = size.height;
    final Color light = Color.lerp(palette.primarySoft, Colors.white, 0.55)!;
    final Color mid = palette.primarySoft;
    final Color deep = palette.primary;

    for (int i = 0; i < petalCount; i++) {
      // Deterministic per-petal parameters spread by the golden ratio.
      final double seed = i * 0.61803398875;
      final double startX = 0.05 + ((seed * 7.13) % 0.9);
      final double speed = 1.2 + ((seed * 3.7) % 1.0) * 0.8;
      final double offset = (seed * 11.7) % 1.2;
      final double swayAmp = w * (0.018 + ((seed * 5.3) % 1.0) * 0.025);
      final double swayCycles = 1.0 + ((seed * 2.9) % 1.0) * 2.0;
      final double phase = (seed * 13.1) % 1.0;
      final double spinCycles = 0.8 + ((seed * 4.4) % 1.0) * 1.4;
      final double petalSize = w * (0.008 + ((seed * 6.1) % 1.0) * 0.006);

      final double y = ((progress * speed + offset) % 1.2) - 0.1;
      final double x =
          startX * w +
          math.sin(2 * math.pi * (progress * swayCycles + phase)) * swayAmp;
      final double angle = 2 * math.pi * (progress * spinCycles + phase);

      final Color color = switch (i % 3) {
        0 => light,
        1 => mid,
        _ => deep,
      };

      canvas.save();
      canvas.translate(x, y * h);
      canvas.rotate(angle);
      canvas.drawPath(
        _petalPath(petalSize),
        Paint()
          ..color = color.withValues(alpha: 0.55 + ((seed * 8.8) % 1.0) * 0.3),
      );
      canvas.restore();
    }
  }

  /// A sakura petal: rounded body with a small notch at the outer tip.
  Path _petalPath(double s) => Path()
    ..moveTo(0, s)
    ..quadraticBezierTo(s * 0.9, s * 0.2, s * 0.42, -s * 0.8)
    ..quadraticBezierTo(0, -s * 0.45, -s * 0.42, -s * 0.8)
    ..quadraticBezierTo(-s * 0.9, s * 0.2, 0, s)
    ..close();

  @override
  bool shouldRepaint(covariant _SakuraScenePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
