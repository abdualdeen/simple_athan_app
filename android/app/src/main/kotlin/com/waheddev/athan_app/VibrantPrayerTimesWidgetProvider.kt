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

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews

/**
 * A colourful home screen widget that paints each prayer as a panel of sky:
 * indigo dawn, bright midday, violet afternoon, coral sunset and starry night.
 *
 * It reads the same week of times the Flutter app pushes for the compact
 * widget, so both stay in sync. The next prayer gets a glowing outline.
 */
class VibrantPrayerTimesWidgetProvider : AppWidgetProvider() {

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
        private val ACCENT = Color.rgb(0xFF, 0xE0, 0x8A)
        private val ACCENT_DARK = Color.rgb(0x8A, 0x6D, 0x12)
        private val AMBER_DARK = Color.rgb(0x8A, 0x4A, 0x12)
        private val INK_DAWN = Color.rgb(0x1B, 0x2A, 0x4A)
        private val INK_NOON = Color.rgb(0x0F, 0x2A, 0x4A)
        private val INK_GOLD = Color.rgb(0x2A, 0x24, 0x18)
        private val TEXT_LIGHT = Color.rgb(0xFF, 0xFF, 0xFF)
        private val MUTED_DAWN = Color.rgb(0x6A, 0x5A, 0x6A)
        private val MUTED_NOON = Color.rgb(0x5A, 0x7A, 0x9A)
        private val MUTED_GOLD = Color.rgb(0x6A, 0x5A, 0x3A)
        private val MUTED_SUNSET = Color.rgb(0xFF, 0xE0, 0xD0)
        private val MUTED_NIGHT = Color.rgb(0xA8, 0xB0, 0xC8)

        // Labels sit on the horizon colour, so the light dawn, noon and
        // afternoon horizons use dark ink while sunset and night stay white.
        private val NAME_COLORS = intArrayOf(
            INK_DAWN, INK_NOON, INK_GOLD, TEXT_LIGHT, TEXT_LIGHT,
        )
        private val TIME_COLORS = intArrayOf(
            INK_DAWN, INK_NOON, INK_GOLD, TEXT_LIGHT, TEXT_LIGHT,
        )
        private val MUTED_COLORS = intArrayOf(
            MUTED_DAWN, MUTED_NOON, MUTED_GOLD, MUTED_SUNSET, MUTED_NIGHT,
        )
        private val NEXT_NAME_COLORS = intArrayOf(
            AMBER_DARK, ACCENT_DARK, AMBER_DARK, ACCENT, ACCENT,
        )

        private val PRAYER_NAME_IDS = intArrayOf(
            R.string.prayer_fajr,
            R.string.prayer_dhuhr,
            R.string.prayer_asr,
            R.string.prayer_maghrib,
            R.string.prayer_isha,
        )
        private val NAME_IDS = intArrayOf(
            R.id.vibrant_name_0,
            R.id.vibrant_name_1,
            R.id.vibrant_name_2,
            R.id.vibrant_name_3,
            R.id.vibrant_name_4,
        )
        private val TIME_IDS = intArrayOf(
            R.id.vibrant_time_0,
            R.id.vibrant_time_1,
            R.id.vibrant_time_2,
            R.id.vibrant_time_3,
            R.id.vibrant_time_4,
        )
        private val HIGHLIGHT_IDS = intArrayOf(
            R.id.vibrant_highlight_0,
            R.id.vibrant_highlight_1,
            R.id.vibrant_highlight_2,
            R.id.vibrant_highlight_3,
            R.id.vibrant_highlight_4,
        )

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, VibrantPrayerTimesWidgetProvider::class.java),
            )
            for (id in ids) {
                manager.updateAppWidget(id, buildRemoteViews(context))
            }
        }

        private fun buildRemoteViews(context: Context): RemoteViews {
            val prefs = PrayerWidgetSupport.prefs(context)
            val views = RemoteViews(context.packageName, R.layout.prayer_times_widget_vibrant)

            val location = prefs.getString(PrayerWidgetSupport.KEY_LOCATION, null)
                ?.let(PrayerWidgetSupport::compactLocationName)
                ?: context.getString(R.string.widget_default_title)
            views.setTextViewText(R.id.vibrant_location, location)

            val today = PrayerWidgetSupport.currentEpochDay()
            var times: List<Long>? = null
            var dayOffset = 0
            for (offset in 0 until PrayerWidgetSupport.DAYS_STORED) {
                times = PrayerWidgetSupport.readDay(prefs, today + offset)
                if (times != null) {
                    dayOffset = offset
                    break
                }
            }

            val now = System.currentTimeMillis()
            val dayTimes = times
            val highlighted = dayTimes?.indexOfFirst { it > now } ?: -1

            for (i in 0 until PrayerWidgetSupport.PRAYER_COUNT) {
                views.setViewVisibility(HIGHLIGHT_IDS[i], View.GONE)
                if (dayTimes == null || i >= dayTimes.size) {
                    views.setTextViewText(TIME_IDS[i], "--:--")
                    views.setTextColor(NAME_IDS[i], MUTED_COLORS[i])
                    views.setTextColor(TIME_IDS[i], MUTED_COLORS[i])
                    continue
                }
                val isNext = i == highlighted
                views.setTextViewText(TIME_IDS[i], PrayerWidgetSupport.formatTime(dayTimes[i]))
                views.setTextColor(
                    NAME_IDS[i],
                    if (isNext) NEXT_NAME_COLORS[i] else NAME_COLORS[i],
                )
                views.setTextColor(TIME_IDS[i], TIME_COLORS[i])
                if (isNext) {
                    views.setViewVisibility(HIGHLIGHT_IDS[i], View.VISIBLE)
                    views.setInt(
                        HIGHLIGHT_IDS[i],
                        "setBackgroundResource",
                        if (i <= 2) R.drawable.widget_vibrant_highlight_dark
                        else R.drawable.widget_vibrant_highlight,
                    )
                }
            }

            val summary = nextSummary(
                context,
                prefs,
                dayTimes,
                highlighted,
                today + dayOffset,
            )
            views.setTextViewText(R.id.vibrant_next, summary)
            views.setOnClickPendingIntent(
                R.id.vibrant_root,
                PrayerWidgetSupport.openAppIntent(context),
            )
            views.setContentDescription(
                R.id.vibrant_root,
                context.getString(R.string.widget_content_description, location, summary),
            )
            return views
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
                    PrayerWidgetSupport.formatTime(times[highlighted]),
                )
            }
            // Every prayer has passed today; point at tomorrow's Fajr instead
            // of leaving the header empty.
            val tomorrow = PrayerWidgetSupport.readDay(prefs, epochDay + 1)
            if (tomorrow != null) {
                return context.getString(
                    R.string.widget_tomorrow_summary,
                    context.getString(PRAYER_NAME_IDS[0]),
                    PrayerWidgetSupport.formatTime(tomorrow[0]),
                )
            }
            return context.getString(R.string.widget_no_times)
        }
    }
}
