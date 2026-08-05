package com.hgdroid.prayer_qibla

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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
        val scheduleJson = widgetData.getString("prayer_schedule_json", null)

        var prayerLabel = context.getString(R.string.widget_default_prayer)
        var prayerTime = context.getString(R.string.widget_default_time)

        if (scheduleJson != null) {
            val now = System.currentTimeMillis()
            val schedule = JSONArray(scheduleJson)
            for (i in 0 until schedule.length()) {
                val entry = schedule.getJSONObject(i)
                if (entry.getLong("millis") >= now) {
                    prayerLabel = entry.getString("label")
                    prayerTime = entry.getString("display")
                    break
                }
            }
        }

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget)
            views.setTextViewText(R.id.widget_header, header)
            views.setTextViewText(R.id.widget_prayer_name, prayerLabel)
            views.setTextViewText(R.id.widget_prayer_time, prayerTime)
            views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_prayer_name, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_prayer_time, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
