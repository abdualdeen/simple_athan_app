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
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone

/**
 * Home screen widget showing the five daily prayer times.
 *
 * The Flutter app pushes the coming week's times through a MethodChannel;
 * this provider stores them in SharedPreferences and renders the set matching
 * the current day, highlighting the next prayer. Periodic system updates and
 * the DATE_CHANGED broadcast keep the highlight fresh without opening the app.
 */
class PrayerTimesWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            manager.updateAppWidget(id, buildRemoteViews(context))
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> refresh(context)
        }
    }

    companion object {
        private const val PREFS = "prayer_widget"
        private const val KEY_LOCATION = "location"
        private const val KEY_DAY_PREFIX = "day_"
        private const val PRAYER_COUNT = 5
        private const val DAYS_STORED = 7
        private const val MILLIS_PER_DAY = 86_400_000L

        private val ACCENT_COLOR = Color.rgb(0xE0, 0xC1, 0x5C)
        private val ACCENT_SOFT_COLOR = Color.rgb(0xF0, 0xDC, 0xA0)
        private val TEXT_COLOR = Color.rgb(0xEA, 0xF2, 0xEE)
        private val MUTED_COLOR = Color.rgb(0x9A, 0xA8, 0xA2)

        private val PRAYER_NAME_IDS = intArrayOf(
            R.string.prayer_fajr,
            R.string.prayer_dhuhr,
            R.string.prayer_asr,
            R.string.prayer_maghrib,
            R.string.prayer_isha,
        )
        private val NAME_IDS = intArrayOf(
            R.id.prayer_name_0,
            R.id.prayer_name_1,
            R.id.prayer_name_2,
            R.id.prayer_name_3,
            R.id.prayer_name_4,
        )
        private val TIME_IDS = intArrayOf(
            R.id.prayer_time_0,
            R.id.prayer_time_1,
            R.id.prayer_time_2,
            R.id.prayer_time_3,
            R.id.prayer_time_4,
        )
        private val CHIP_IDS = intArrayOf(
            R.id.prayer_chip_0,
            R.id.prayer_chip_1,
            R.id.prayer_chip_2,
            R.id.prayer_chip_3,
            R.id.prayer_chip_4,
        )

        fun prefs(context: Context): SharedPreferences =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        fun currentEpochDay(): Long {
            // Day boundaries must match the local dates the schedules were
            // computed for, not UTC — otherwise the widget flips to the next
            // day's times at 19:00 EST instead of midnight.
            val now = System.currentTimeMillis()
            return (now + TimeZone.getDefault().getOffset(now)) / MILLIS_PER_DAY
        }

        private fun buildRemoteViews(context: Context): RemoteViews {
            val prefs = prefs(context)
            val views = RemoteViews(context.packageName, R.layout.prayer_times_widget)

            val location = prefs.getString(KEY_LOCATION, null)
                ?.let(::compactLocationName)
                ?: context.getString(R.string.widget_default_title)
            views.setTextViewText(R.id.widget_location, location)

            val today = currentEpochDay()
            var times: List<Long>? = null
            var dayOffset = 0
            for (offset in 0 until DAYS_STORED) {
                times = readDay(prefs, today + offset)
                if (times != null) {
                    dayOffset = offset
                    break
                }
            }

            val now = System.currentTimeMillis()
            val dayTimes = times
            val highlighted = dayTimes?.indexOfFirst { it > now } ?: -1

            for (i in 0 until PRAYER_COUNT) {
                if (dayTimes == null || i >= dayTimes.size) {
                    views.setInt(
                        CHIP_IDS[i],
                        "setBackgroundResource",
                        R.drawable.widget_prayer_chip,
                    )
                    views.setTextViewText(TIME_IDS[i], "--:--")
                    views.setTextColor(NAME_IDS[i], MUTED_COLOR)
                    views.setTextColor(TIME_IDS[i], MUTED_COLOR)
                    continue
                }
                val isNext = i == highlighted
                views.setInt(
                    CHIP_IDS[i],
                    "setBackgroundResource",
                    if (isNext) R.drawable.widget_prayer_chip_next
                    else R.drawable.widget_prayer_chip,
                )
                views.setTextViewText(TIME_IDS[i], formatTime(dayTimes[i]))
                views.setTextColor(
                    NAME_IDS[i],
                    if (isNext) ACCENT_SOFT_COLOR else MUTED_COLOR,
                )
                views.setTextColor(
                    TIME_IDS[i],
                    if (isNext) ACCENT_COLOR else TEXT_COLOR,
                )
            }

            val summary = nextSummary(
                context,
                prefs,
                dayTimes,
                highlighted,
                today + dayOffset,
            )
            views.setTextViewText(R.id.widget_next, summary)
            views.setOnClickPendingIntent(R.id.widget_root, openAppIntent(context))
            views.setContentDescription(
                R.id.widget_root,
                context.getString(R.string.widget_content_description, location, summary),
            )
            return views
        }

        /**
         * The widget header is one line, so the city alone is friendlier than a
         * long `city, state, country` string. Coordinate labels contain a comma
         * too, so they are kept whole.
         */
        private fun compactLocationName(name: String): String {
            val city = name.substringBefore(',').trim()
            if (city.isEmpty()) return name
            return if (city.endsWith("°") && name.contains("°")) name else city
        }

        private fun nextSummary(
            context: Context,
            prefs: SharedPreferences,
            times: List<Long>?,
            highlighted: Int,
            epochDay: Long,
        ): String {
            if (times == null) return context.getString(R.string.widget_no_times)
            if (highlighted >= 0) {
                return context.getString(
                    R.string.widget_next_summary,
                    context.getString(PRAYER_NAME_IDS[highlighted]),
                    formatTime(times[highlighted]),
                )
            }
            // Every prayer has passed today; point at tomorrow's Fajr instead
            // of leaving the header empty.
            val tomorrow = readDay(prefs, epochDay + 1)
            if (tomorrow != null) {
                return context.getString(
                    R.string.widget_tomorrow_summary,
                    context.getString(PRAYER_NAME_IDS[0]),
                    formatTime(tomorrow[0]),
                )
            }
            return context.getString(R.string.widget_no_times)
        }

        private fun openAppIntent(context: Context): PendingIntent {
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

        private fun readDay(prefs: SharedPreferences, epochDay: Long): List<Long>? {
            val raw = prefs.getString(KEY_DAY_PREFIX + epochDay, null) ?: return null
            val times = raw.split(",").mapNotNull { it.toLongOrNull() }
            return if (times.size >= PRAYER_COUNT) times else null
        }

        private fun formatTime(millis: Long): String {
            val calendar = Calendar.getInstance().apply { timeInMillis = millis }
            val hour = calendar.get(Calendar.HOUR)
            val minute = calendar.get(Calendar.MINUTE)
            val amPm = if (calendar.get(Calendar.AM_PM) == Calendar.AM) "AM" else "PM"
            val hour12 = if (hour == 0) 12 else hour
            return String.format(Locale.US, "%d:%02d %s", hour12, minute, amPm)
        }

        /** Saves the pushed days (index 0 = today) and refreshes the widgets. */
        fun saveAndRefresh(context: Context, locationName: String, days: List<*>?) {
            if (days == null) return
            val editor = prefs(context).edit()
            editor.putString(KEY_LOCATION, locationName)
            val today = currentEpochDay()
            for (i in days.indices) {
                if (i >= DAYS_STORED) break
                val day = days[i] as? List<*> ?: continue
                val times = day.mapNotNull { (it as? Number)?.toLong() }
                if (times.size < PRAYER_COUNT) continue
                editor.putString(KEY_DAY_PREFIX + (today + i), times.joinToString(","))
            }
            editor.apply()
            refresh(context)
        }

        private fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, PrayerTimesWidgetProvider::class.java),
            )
            for (id in ids) {
                manager.updateAppWidget(id, buildRemoteViews(context))
            }
        }
    }
}
