import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/hijri_date.dart';

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
    final HijriDate hijri = HijriDate.fromDateTime(date);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.emeraldSoft,
            AppColors.emerald,
            AppColors.emeraldDeep,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _HeaderPatternPainter()),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _RoundIconButton(
                        icon: Icons.menu_rounded,
                        tooltip: 'Open menu',
                        onTap: onMenuTap,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _LocationPill(
                            name: locationName,
                            isLocating: isLocating,
                            onTap: onLocationTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Assalamu Alaikum',
                    style: TextStyle(
                      color: AppColors.goldSoft,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.nightlight_round,
                        size: 14,
                        color: AppColors.goldSoft,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          hijri.formatted,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 22),
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
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.goldSoft,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (isLocating)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.goldSoft,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.75),
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
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.10)
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
      ..color = AppColors.gold.withValues(alpha: 0.22)
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
  bool shouldRepaint(covariant _HeaderPatternPainter oldDelegate) => false;
}
