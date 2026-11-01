import 'package:flutter/material.dart';

import '../data/prayer_times_service.dart';
import '../models/prayer.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// The list of today's prayer times, highlighting the upcoming prayer.
class PrayerList extends StatelessWidget {
  const PrayerList({
    super.key,
    required this.now,
    required this.muted,
    required this.onToggleMute,
  });

  final DateTime now;
  final Set<PrayerId> muted;
  final ValueChanged<PrayerId> onToggleMute;

  @override
  Widget build(BuildContext context) {
    final PrayerSchedule schedule = PrayerTimesService.forDate(now);
    final PrayerTime next = PrayerTimesService.nextPrayer(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Today's Prayers",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text(
                '${schedule.prayers.length} times',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adhan times for ${PrayerTimesService.locationName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final PrayerTime prayer in schedule.prayers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PrayerTile(
                prayer: prayer,
                isNext: prayer.id == next.id,
                isMuted: muted.contains(prayer.id),
                onToggleMute: () => onToggleMute(prayer.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.prayer,
    required this.isNext,
    required this.isMuted,
    required this.onToggleMute,
  });

  final PrayerTime prayer;
  final bool isNext;
  final bool isMuted;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isNext ? Colors.white : AppColors.ink;
    final Color subtitleColor = isNext
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.inkMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: isNext ? AppColors.emerald : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: isNext
            ? null
            : Border.all(color: AppColors.emerald.withValues(alpha: 0.07)),
        boxShadow: isNext
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isNext
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.cream,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              prayer.icon,
              size: 20,
              color: isNext ? AppColors.goldSoft : AppColors.emerald,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        prayer.label,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    if (isNext) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.emeraldDeep,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  prayer.arabicLabel,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                formatClockTime(prayer.time),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                prayer.isPrayer ? 'Adhan' : 'Shuruq',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          if (prayer.isPrayer)
            IconButton(
              onPressed: onToggleMute,
              tooltip: isMuted
                  ? 'Unmute ${prayer.label}'
                  : 'Mute ${prayer.label}',
              visualDensity: VisualDensity.compact,
              iconSize: 19,
              color: isNext ? AppColors.goldSoft : AppColors.inkMuted,
              icon: Icon(
                isMuted
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_active_outlined,
              ),
            ),
        ],
      ),
    );
  }
}
