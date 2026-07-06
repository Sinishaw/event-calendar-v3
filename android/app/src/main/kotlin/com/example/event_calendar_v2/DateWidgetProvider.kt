package com.example.event_calendar_v2

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Home-screen widget: full Ethiopian date on top, full Gregorian date below.
///
/// The strings are computed in Dart (HomeWidgetService) and stored via
/// home_widget's SharedPreferences; here we just render them into the layout.
class DateWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Tapping anywhere on the widget opens the app (calendar).
        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_date).apply {
                setTextViewText(R.id.tv_et_date, widgetData.getString("date_et", "") ?: "")
                setTextViewText(R.id.tv_gc_date, widgetData.getString("date_gc", "") ?: "")
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
