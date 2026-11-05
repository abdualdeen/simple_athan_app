import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/hijri_date.dart';
import '../utils/location_name.dart';
import 'nightsky_scene.dart';
import 'olive_scene.dart';
import 'sakura_scene.dart';

/// Gradient header with the menu button, current location, and both the
/// Gregorian and Hijri dates.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.date,
    required this.locationName,
    required this.onMenuTap,
    required this.onLocationTap,
    this.isLocating = false,
  });

  final DateTime date;
  final String locationName;
  final VoidCallback onMenuTap;
  final VoidCallback onLocationTap;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final HijriDate hijri = HijriDate.fromDateTime(date);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.headerGradient,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: switch (palette.motif) {
                AppMotif.sakura => const SakuraScene(),
                AppMotif.olive => const OliveScene(),
                AppMotif.nightSky => const NightSkyScene(),
                AppMotif.crescent => CustomPaint(
                  painter: _HeaderPatternPainter(color: palette.accent),
                ),
              },
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _LocationPill(
                            name: abbreviateLocationName(locationName),
                            isLocating: isLocating,
                            onTap: onLocationTap,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _RoundIconButton(
                        icon: Icons.menu_rounded,
                        tooltip: 'Open menu',
                        onTap: onMenuTap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Assalamu Alaikum',
                    style: TextStyle(
                      color: palette.accentSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatGregorianDate(date),
                      maxLines: 1,
                      style: TextStyle(
                        color: palette.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.nightlight_round,
                        size: 14,
                        color: palette.accentSoft,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          hijri.formatted,
                          style: TextStyle(
                            color: palette.onPrimary.withValues(alpha: 0.82),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.onPrimary.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: palette.onPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.name,
    required this.onTap,
    this.isLocating = false,
  });

  final String name;
  final VoidCallback onTap;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: palette.onPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: palette.accentSoft,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (isLocating)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      palette.accentSoft,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: palette.onPrimary.withValues(alpha: 0.75),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle crescent and star motif painted behind the header content.
class _HeaderPatternPainter extends CustomPainter {
  const _HeaderPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final Path outer = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.94, size.height * 0.12),
          radius: size.width * 0.30,
        ),
      );
    final Path inner = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.82, size.height * 0.03),
          radius: size.width * 0.27,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      paint,
    );

    final Paint starPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    _drawSparkle(
      canvas,
      Offset(size.width * 0.16, size.height * 0.34),
      5,
      starPaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.30, size.height * 0.18),
      3.5,
      starPaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.72, size.height * 0.42),
      4,
      starPaint,
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
  bool shouldRepaint(covariant _HeaderPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
