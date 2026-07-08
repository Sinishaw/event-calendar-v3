package com.example.event_calendar_v2

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// "Date card" home-screen widget: big Ethiopian day number, the Ethiopian
/// weekday down the right edge, the Ethiopian month + year below the day, and
/// the full Gregorian date across the bottom.
///
/// All strings are computed in Dart (HomeWidgetService) and stored via
/// home_widget's SharedPreferences; here we just render them into the layout.
class DateCardWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Tapping anywhere on the widget opens the app (calendar).
        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_date_card).apply {
                setTextViewText(R.id.tv_card_day, widgetData.getString("et_day", "") ?: "")
                setTextViewText(R.id.tv_card_month_year, widgetData.getString("et_month_year", "") ?: "")
                setTextViewText(R.id.tv_card_weekday, widgetData.getString("et_weekday", "") ?: "")
                setTextViewText(R.id.tv_card_gc, widgetData.getString("date_gc", "") ?: "")
                setOnClickPendingIntent(R.id.widget_card_root, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
