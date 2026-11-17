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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prayer.dart';
import '../models/prayer_schedule.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// The prayer times for a single day, highlighting the upcoming prayer, with
/// controls to browse previous and future days.
class PrayerList extends StatelessWidget {
  const PrayerList({
    super.key,
    required this.schedule,
    required this.date,
    required this.dayOffset,
    required this.nextId,
    required this.muted,
    required this.onToggleMute,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onBackToToday,
    required this.onPickDate,
  });

  final PrayerSchedule schedule;

  /// The date being shown, at local midnight.
  final DateTime date;

  /// Days between [date] and today; `0` shows today.
  final int dayOffset;

  /// The id of the upcoming prayer, or `null` when [date] is not today so no
  /// row is highlighted.
  final PrayerId? nextId;
  final Set<PrayerId> muted;
  final ValueChanged<PrayerId> onToggleMute;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onBackToToday;

  /// Opens a date picker to jump straight to a chosen day.
  final VoidCallback onPickDate;

  bool get _isToday => dayOffset == 0;

  String get _title {
    if (_isToday) return "Today's Prayers";
    if (dayOffset == -1) return 'Yesterday';
    if (dayOffset == 1) return 'Tomorrow';
    return formatGregorianDate(date);
  }

  String get _subtitle {
    if (_isToday) return 'Adhan times for today';
    if (dayOffset == -1 || dayOffset == 1) return formatGregorianDate(date);
    return 'Adhan times';
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onPreviousDay();
                },
                tooltip: 'Previous day',
                iconSize: 26,
                color: palette.primary,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Tooltip(
                  message: 'Jump to a date',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onPickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 16,
                                color: palette.inkMuted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onNextDay();
                },
                tooltip: 'Next day',
                iconSize: 26,
                color: palette.primary,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (!_isToday)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Material(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onBackToToday,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.today_outlined,
                            size: 15,
                            color: palette.label,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Back to today',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: palette.label,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          for (final PrayerTime prayer in schedule.prayers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PrayerTile(
                prayer: prayer,
                isNext: prayer.id == nextId,
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
        // Every tile carries a border so the highlighted row — whose border
        // matches its own background and stays invisible — has the same
        // geometry as the rest; otherwise rows shift by the border width.
        border: Border.all(
          color: isNext
              ? palette.primary
              : palette.primary.withValues(alpha: 0.07),
        ),
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
          // Every row reserves the mute button's space so the time column
          // ends at the same position; sunrise's slot is simply empty.
          SizedBox(
            width: 40,
            height: 42,
            child: prayer.isPrayer
                ? IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onToggleMute();
                    },
                    tooltip: isMuted
                        ? 'Unmute ${prayer.label}'
                        : 'Mute ${prayer.label}',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    iconSize: 19,
                    color: isNext ? palette.accentSoft : palette.inkMuted,
                    icon: Icon(
                      isMuted
                          ? Icons.notifications_off_outlined
                          : Icons.notifications_active_outlined,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
