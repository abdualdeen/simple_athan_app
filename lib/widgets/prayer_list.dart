import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../models/prayer_schedule.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// The list of today's prayer times, highlighting the upcoming prayer.
class PrayerList extends StatelessWidget {
  const PrayerList({
    super.key,
    required this.day,
    required this.muted,
    required this.onToggleMute,
  });

  final PrayerDay day;
  final Set<PrayerId> muted;
  final ValueChanged<PrayerId> onToggleMute;

  @override
  Widget build(BuildContext context) {
    final PrayerSchedule schedule = day.schedule;

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
            'Adhan times for today',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final PrayerTime prayer in schedule.prayers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PrayerTile(
                prayer: prayer,
                isNext: prayer.id == day.next.id,
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
    final AppPalette palette = context.palette;
    final Color titleColor = isNext ? palette.onPrimary : palette.ink;
    final Color subtitleColor = isNext
        ? palette.onPrimary.withValues(alpha: 0.7)
        : palette.inkMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: isNext ? palette.primary : palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: isNext
            ? null
            : Border.all(color: palette.primary.withValues(alpha: 0.07)),
        boxShadow: isNext
            ? <BoxShadow>[
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.25),
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
                  ? palette.onPrimary.withValues(alpha: 0.12)
                  : palette.background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              prayer.icon,
              size: 20,
              color: isNext ? palette.accentSoft : palette.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  prayer.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        prayer.arabicLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: subtitleColor),
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
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: palette.primaryDeep,
                          ),
                        ),
                      ),
                    ],
                  ],
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
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              iconSize: 19,
              color: isNext ? palette.accentSoft : palette.inkMuted,
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
