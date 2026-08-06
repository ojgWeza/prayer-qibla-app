package com.hgdroid.prayer_qibla

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * Shows the next upcoming prayer on the home screen. The Flutter side
 * (widget_service.dart) pushes the whole rolling schedule (today plus
 * several days ahead, same window as the notification scheduler) as JSON
 * whenever it recomputes prayer times. This provider only has to pick the
 * first entry that hasn't passed yet, so Android's periodic
 * [AppWidgetProviderInfo.updatePeriodMillis] refresh keeps the widget
 * correct even when the app itself isn't opened for a while.
 */
class NextPrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val header = widgetData.getString("next_prayer_header", null)
            ?: context.getString(R.string.widget_default_header)
        // RemoteViews is inflated by the launcher process using the *system*
        // locale, not Flutter's in-app language override, so supportsRtl
        // alone can't mirror this widget for the app's own Arabic setting.
        // Set layoutDirection explicitly from the language the app actually
        // pushed instead of relying on automatic system-locale mirroring.
        val isRtl = widgetData.getString("language", "ar") == "ar"
        val scheduleJson = widgetData.getString("prayer_schedule_json", null)
        // Localized "{h} hours & {m} minutes remaining" / "{m} minutes
        // remaining" templates, pushed from the same AppStrings entries the
        // in-app countdown uses (see prayer_times_screen.dart), so the
        // widget's countdown text matches the app's wording/language.
        val hoursMinutesTemplate = widgetData.getString("remaining_hours_minutes_template", null)
        val minutesTemplate = widgetData.getString("remaining_minutes_template", null)

        var prayerLabel = context.getString(R.string.widget_default_prayer)
        var prayerTime = context.getString(R.string.widget_default_time)
        var countdownText = ""

        if (scheduleJson != null) {
            val now = System.currentTimeMillis()
            val schedule = JSONArray(scheduleJson)
            for (i in 0 until schedule.length()) {
                val entry = schedule.getJSONObject(i)
                val millis = entry.getLong("millis")
                if (millis >= now) {
                    prayerLabel = entry.getString("label")
                    prayerTime = entry.getString("display")
                    countdownText = formatRemaining(
                        millis - now,
                        hoursMinutesTemplate,
                        minutesTemplate,
                    )
                    break
                }
            }
        }

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget)
            views.setInt(
                R.id.widget_root,
                "setLayoutDirection",
                if (isRtl) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR,
            )
            views.setTextViewText(R.id.widget_header, header)
            views.setTextViewText(R.id.widget_prayer_name, prayerLabel)
            views.setTextViewText(R.id.widget_prayer_time, prayerTime)
            views.setTextViewText(R.id.widget_countdown, countdownText)
            views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_prayer_name, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_prayer_time, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun formatRemaining(
        remainingMillis: Long,
        hoursMinutesTemplate: String?,
        minutesTemplate: String?,
    ): String {
        val clamped = remainingMillis.coerceAtLeast(0)
        val totalMinutes = clamped / 60000
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        val template = if (hours > 0) hoursMinutesTemplate else minutesTemplate
        return template
            ?.replace("{h}", hours.toString())
            ?.replace("{m}", minutes.toString())
            ?: ""
    }
}
