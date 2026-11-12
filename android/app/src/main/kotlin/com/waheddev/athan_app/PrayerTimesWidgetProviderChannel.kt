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

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Exposes the prayer times widget to the Flutter side. */
object PrayerTimesWidgetProviderChannel {
    private const val CHANNEL = "athan_app/home_widget"

    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updatePrayerTimes" -> {
                    val args = call.arguments as? Map<*, *>
                    val locationName = args?.get("locationName") as? String
                    val days = args?.get("days") as? List<*>
                    if (locationName == null || days == null) {
                        result.error("bad_args", "Missing widget arguments", null)
                        return@setMethodCallHandler
                    }
                    PrayerTimesWidgetProvider.saveAndRefresh(context, locationName, days)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
