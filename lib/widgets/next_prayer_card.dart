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
    final AppPalette palette = context.palette;
    final PrayerTime next = day.next;
    final PrayerTime previous = day.previous;
    final Duration remaining = next.time.difference(now);
    final int span = next.time.difference(previous.time).inSeconds;
    final int elapsed = now.difference(previous.time).inSeconds;
    final double progress = span <= 0 ? 0 : (elapsed / span).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.18),
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
                  gradient: LinearGradient(
                    colors: <Color>[palette.primarySoft, palette.primary],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(next.icon, color: palette.accentSoft, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'NEXT PRAYER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.accentDark,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.inkMuted,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: palette.label,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
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
              backgroundColor: palette.background,
              valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                '${previous.label} ${formatClockTime(previous.time)}',
                style: _captionStyle(palette),
              ),
              const Spacer(),
              Text(
                '${next.label} ${formatClockTime(next.time)}',
                style: _captionStyle(palette),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _captionStyle(AppPalette palette) => TextStyle(
    fontSize: 11,
    color: palette.inkMuted,
    fontWeight: FontWeight.w500,
  );
}
