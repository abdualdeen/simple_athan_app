import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../models/prayer_schedule.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// Floating card showing the upcoming prayer and a live countdown.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key, required this.now, required this.day});

  final DateTime now;
  final PrayerDay day;

  @override
  Widget build(BuildContext context) {
    final PrayerTime next = day.next;
    final PrayerTime previous = day.previous;
    final Duration remaining = next.time.difference(now);
    final int span = next.time.difference(previous.time).inSeconds;
    final int elapsed = now.difference(previous.time).inSeconds;
    final double progress = span <= 0 ? 0 : (elapsed / span).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.emeraldSoft, AppColors.emerald],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(next.icon, color: AppColors.goldSoft, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'NEXT PRAYER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.goldDark,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      formatClockTime(next.time),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    formatCountdown(remaining),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'remaining',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(letterSpacing: 0.6),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.cream,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.emerald,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                '${previous.label} ${formatClockTime(previous.time)}',
                style: _captionStyle,
              ),
              const Spacer(),
              Text(
                '${next.label} ${formatClockTime(next.time)}',
                style: _captionStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _captionStyle = TextStyle(
    fontSize: 11,
    color: AppColors.inkMuted,
    fontWeight: FontWeight.w500,
  );
}
