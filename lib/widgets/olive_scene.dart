import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated decorative scene for the olive theme: olive branches reaching in
/// from the right, a sun behind the menu button, and leaves drifting down.
class OliveScene extends StatefulWidget {
  const OliveScene({super.key});

  @override
  State<OliveScene> createState() => _OliveSceneState();
}

class _OliveSceneState extends State<OliveScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
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
          painter: _OliveScenePainter(
            palette: palette,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _OliveScenePainter extends CustomPainter {
  const _OliveScenePainter({required this.palette, required this.progress});

  final AppPalette palette;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSun(canvas, size);
    _paintTree(canvas, size);
    _paintDriftingLeaves(canvas, size);
  }

  /// Warm sun tucked behind the menu button in the top-left corner, with
  /// slowly rotating rays.
  void _paintSun(Canvas canvas, Size size) {
    final double radius = size.width * 0.075;
    final Offset center = Offset(size.width * 0.105, size.height * 0.20);

    canvas.drawCircle(
      center,
      radius * 1.7,
      Paint()..color = palette.accentSoft.withValues(alpha: 0.12),
    );

    final Paint rayPaint = Paint()
      ..color = palette.accentSoft.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final double angle = i * math.pi / 6 + progress * math.pi;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * radius * 1.3,
        center + direction * radius * 1.65,
        rayPaint,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = palette.accent.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      center,
      radius * 0.7,
      Paint()..color = palette.accentSoft.withValues(alpha: 0.9),
    );
  }

  /// Olive branches reaching in from the right edge, with slender leaves and
  /// a few olives.
  void _paintTree(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Color bark = palette.primaryDeep.withValues(alpha: 0.9);
    final Color leafLight = Color.lerp(
      palette.primarySoft,
      Colors.white,
      0.35,
    )!;
    final Color leafMid = palette.primarySoft;
    final Color leafDeep = palette.primary;

    // Main branches entering from the right edge, tapering as they reach in.
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.34),
      Offset(w * 0.78, h * 0.30),
      Offset(w * 0.52, h * 0.20),
      w * 0.018,
      w * 0.005,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.52),
      Offset(w * 0.82, h * 0.48),
      Offset(w * 0.63, h * 0.38),
      w * 0.015,
      w * 0.004,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 1.02, h * 0.16),
      Offset(w * 0.86, h * 0.15),
      Offset(w * 0.73, h * 0.10),
      w * 0.012,
      w * 0.003,
      bark,
    );
    // Twigs branching off the mains.
    _drawBranch(
      canvas,
      Offset(w * 0.674, h * 0.255),
      Offset(w * 0.63, h * 0.21),
      Offset(w * 0.60, h * 0.15),
      w * 0.006,
      w * 0.003,
      bark,
    );
    _drawBranch(
      canvas,
      Offset(w * 0.784, h * 0.45),
      Offset(w * 0.77, h * 0.40),
      Offset(w * 0.745, h * 0.345),
      w * 0.005,
      w * 0.003,
      bark,
    );

    // Slender olive leaves in pairs along the branches.
    final List<(Offset, double, double, Color)> leaves =
        <(Offset, double, double, Color)>[
          (Offset(w * 0.874, h * 0.311), w * 0.040, -0.7, leafMid),
          (Offset(w * 0.874, h * 0.311), w * 0.036, -2.4, leafLight),
          (Offset(w * 0.775, h * 0.285), w * 0.042, -0.3, leafLight),
          (Offset(w * 0.775, h * 0.285), w * 0.036, -2.8, leafMid),
          (Offset(w * 0.725, h * 0.270), w * 0.038, -0.6, leafDeep),
          (Offset(w * 0.725, h * 0.270), w * 0.034, -2.5, leafLight),
          (Offset(w * 0.674, h * 0.255), w * 0.040, -0.2, leafMid),
          (Offset(w * 0.674, h * 0.255), w * 0.034, -2.6, leafDeep),
          (Offset(w * 0.598, h * 0.229), w * 0.036, -0.5, leafLight),
          (Offset(w * 0.52, h * 0.20), w * 0.038, -0.7, leafMid),
          (Offset(w * 0.8225, h * 0.465), w * 0.040, -0.6, leafLight),
          (Offset(w * 0.8225, h * 0.465), w * 0.034, -2.9, leafMid),
          (Offset(w * 0.706, h * 0.418), w * 0.038, -0.5, leafMid),
          (Offset(w * 0.706, h * 0.418), w * 0.034, -2.6, leafLight),
          (Offset(w * 0.63, h * 0.38), w * 0.038, -0.7, leafDeep),
          (Offset(w * 0.839, h * 0.134), w * 0.036, -0.5, leafMid),
          (Offset(w * 0.839, h * 0.134), w * 0.032, 0.4, leafLight),
          (Offset(w * 0.73, h * 0.10), w * 0.036, -0.6, leafLight),
          (Offset(w * 0.60, h * 0.15), w * 0.034, -0.4, leafMid),
          (Offset(w * 0.745, h * 0.345), w * 0.032, -0.6, leafLight),
        ];
    for (final (Offset center, double length, double angle, Color color)
        in leaves) {
      _drawLeaf(canvas, center, length, angle, color);
    }

    // A few olives hanging near the branches.
    final Paint olivePaint = Paint()..color = bark;
    canvas.drawCircle(Offset(w * 0.72, h * 0.305), w * 0.009, olivePaint);
    canvas.drawCircle(Offset(w * 0.735, h * 0.325), w * 0.008, olivePaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.425), w * 0.009, olivePaint);
    canvas.drawCircle(Offset(w * 0.87, h * 0.36), w * 0.008, olivePaint);
  }

  /// Leaves drifting down with a gentle sway and rock.
  void _paintDriftingLeaves(Canvas canvas, Size size) {
    const int leafCount = 8;
    final double w = size.width;
    final double h = size.height;
    final Color light = Color.lerp(palette.primarySoft, Colors.white, 0.35)!;
    final Color mid = palette.primarySoft;
    final Color deep = palette.primary;

    for (int i = 0; i < leafCount; i++) {
      final double seed = i * 0.61803398875;
      final double startX = 0.05 + ((seed * 7.13) % 0.9);
      final double speed = 0.9 + ((seed * 3.7) % 1.0) * 0.7;
      final double offset = (seed * 11.7) % 1.2;
      final double swayAmp = w * (0.02 + ((seed * 5.3) % 1.0) * 0.03);
      final double swayCycles = 1.0 + ((seed * 2.9) % 1.0) * 2.0;
      final double phase = (seed * 13.1) % 1.0;
      final double length = w * (0.022 + ((seed * 6.1) % 1.0) * 0.014);

      final double y = ((progress * speed + offset) % 1.2) - 0.1;
      final double x =
          startX * w +
          math.sin(2 * math.pi * (progress * swayCycles + phase)) * swayAmp;
      final double angle =
          math.sin(2 * math.pi * (progress * swayCycles + phase)) * 0.9;

      final Color color = switch (i % 3) {
        0 => light,
        1 => mid,
        _ => deep,
      };

      canvas.save();
      canvas.translate(x, y * h);
      canvas.rotate(angle);
      canvas.drawPath(
        _leafPath(length),
        Paint()
          ..color = color.withValues(alpha: 0.55 + ((seed * 8.8) % 1.0) * 0.25),
      );
      canvas.restore();
    }
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

  /// Slender lance-shaped olive leaf, drawn pointing up before rotation.
  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawPath(_leafPath(length), Paint()..color = color);
    canvas.restore();
  }

  Path _leafPath(double length) => Path()
    ..moveTo(0, -length / 2)
    ..quadraticBezierTo(length * 0.14, 0, 0, length / 2)
    ..quadraticBezierTo(-length * 0.14, 0, 0, -length / 2)
    ..close();

  @override
  bool shouldRepaint(covariant _OliveScenePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
