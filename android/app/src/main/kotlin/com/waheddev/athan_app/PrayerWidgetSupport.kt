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

package com.waheddev.athan_app

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone

/**
 * Storage and formatting shared by the home screen prayer widgets.
 *
 * The Flutter app pushes a week of times through a MethodChannel; both widget
 * providers read the same local epoch-day keys so they always agree.
 */
object PrayerWidgetSupport {
    const val PREFS = "prayer_widget"
    const val KEY_LOCATION = "location"
    const val KEY_DAY_PREFIX = "day_"
    const val PRAYER_COUNT = 5
    const val DAYS_STORED = 7
    const val MILLIS_PER_DAY = 86_400_000L

    fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun currentEpochDay(): Long {
        // Day boundaries must match the local dates the schedules were
        // computed for, not UTC — otherwise the widget flips to the next
        // day's times at 19:00 EST instead of midnight.
        val now = System.currentTimeMillis()
        return (now + TimeZone.getDefault().getOffset(now)) / MILLIS_PER_DAY
    }

    fun readDay(prefs: SharedPreferences, epochDay: Long): List<Long>? {
        val raw = prefs.getString(KEY_DAY_PREFIX + epochDay, null) ?: return null
        val times = raw.split(",").mapNotNull { it.toLongOrNull() }
        return if (times.size >= PRAYER_COUNT) times else null
    }

    fun formatTime(millis: Long): String {
        val calendar = Calendar.getInstance().apply { timeInMillis = millis }
        val hour = calendar.get(Calendar.HOUR)
        val minute = calendar.get(Calendar.MINUTE)
        val amPm = if (calendar.get(Calendar.AM_PM) == Calendar.AM) "AM" else "PM"
        val hour12 = if (hour == 0) 12 else hour
        return String.format(Locale.US, "%d:%02d %s", hour12, minute, amPm)
    }

    /**
     * The widget header is one line, so the city alone is friendlier than a
     * long `city, state, country` string. Coordinate labels contain a comma
     * too, so they are kept whole.
     */
    fun compactLocationName(name: String): String {
        val city = name.substringBefore(',').trim()
        if (city.isEmpty()) return name
        return if (city.endsWith("°") && name.contains("°")) name else city
    }

    fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
