package com.example.event_calendar_v2

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/// Android port of the iOS Large agenda widget: ET/GC dates in the top corners
/// (day on top, weekday + month/year below), up to 4 color-coded upcoming
/// events each on a faint tint of its color, and a "+" to add. Content is
/// computed in Dart (HomeWidgetService) and stored via home_widget.
class AgendaWidgetProvider : HomeWidgetProvider() {

    private val rowIds = intArrayOf(R.id.agenda_row_0, R.id.agenda_row_1, R.id.agenda_row_2, R.id.agenda_row_3)
    private val barIds = intArrayOf(R.id.agenda_bar_0, R.id.agenda_bar_1, R.id.agenda_bar_2, R.id.agenda_bar_3)
    private val titleIds = intArrayOf(R.id.tv_ag_title_0, R.id.tv_ag_title_1, R.id.tv_ag_title_2, R.id.tv_ag_title_3)
    private val detailIds = intArrayOf(R.id.tv_ag_detail_0, R.id.tv_ag_detail_1, R.id.tv_ag_detail_2, R.id.tv_ag_detail_3)
    private val timeIds = intArrayOf(R.id.tv_ag_time_0, R.id.tv_ag_time_1, R.id.tv_ag_time_2, R.id.tv_ag_time_3)

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val openToday = HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java, Uri.parse("eventcalendarwidget://day"))
        val openAdd = HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java, Uri.parse("eventcalendarwidget://add"))

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_agenda)

            // Corner dates: day on top, "weekday, month year" below.
            views.setTextViewText(R.id.tv_ag_et_day, widgetData.getString("ag_et_day", "") ?: "")
            views.setTextViewText(R.id.tv_ag_et_sub, subLine(
                widgetData.getString("ag_et_weekday", "") ?: "",
                widgetData.getString("ag_et_month_year", "") ?: ""))
            views.setTextViewText(R.id.tv_ag_gc_day, widgetData.getString("ag_gc_day", "") ?: "")
            views.setTextViewText(R.id.tv_ag_gc_sub, subLine(
                widgetData.getString("ag_gc_weekday", "") ?: "",
                widgetData.getString("ag_gc_month_year", "") ?: ""))

            // Agenda rows.
            val items = parseAgenda(widgetData.getString("agenda_today", "[]") ?: "[]")
            for (i in 0 until 4) {
                if (i < items.size) {
                    val item = items[i]
                    val color = parseColorSafe(item.colorHex)
                    views.setViewVisibility(rowIds[i], View.VISIBLE)
                    val prefix = if (item.dateLabel.isNotEmpty()) "${item.dateLabel} · " else ""
                    views.setTextViewText(titleIds[i], prefix + item.title)
                    views.setTextViewText(detailIds[i], item.detail)
                    views.setViewVisibility(detailIds[i], if (item.detail.isEmpty()) View.GONE else View.VISIBLE)
                    views.setTextViewText(timeIds[i], item.time)
                    views.setInt(barIds[i], "setBackgroundColor", color)
                    // Faint tint of the event color behind the row (like iOS).
                    views.setInt(rowIds[i], "setBackgroundColor", (color and 0x00FFFFFF) or 0x22000000)
                    // Tapping the event opens its exact day, scrolled to its time.
                    val uri = Uri.parse("eventcalendarwidget://day?d=${item.gcDate}&t=${item.scrollMin}")
                    views.setOnClickPendingIntent(
                        rowIds[i],
                        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri))
                } else {
                    views.setViewVisibility(rowIds[i], View.GONE)
                }
            }
            views.setViewVisibility(R.id.tv_ag_empty, if (items.isEmpty()) View.VISIBLE else View.GONE)
            if (items.isEmpty()) {
                views.setTextViewText(R.id.tv_ag_empty, widgetData.getString("agenda_empty", "") ?: "")
            }

            // Empty area → today's day view; "+" → add-event form.
            views.setOnClickPendingIntent(R.id.widget_agenda_root, openToday)
            views.setOnClickPendingIntent(R.id.btn_ag_add, openAdd)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun subLine(weekday: String, monthYear: String): String {
        return if (weekday.isNotEmpty() && monthYear.isNotEmpty()) "$weekday, $monthYear"
        else weekday + monthYear
    }

    private data class AgendaItem(
        val title: String, val detail: String, val colorHex: String,
        val dateLabel: String, val time: String, val gcDate: String, val scrollMin: Int)

    private fun parseAgenda(json: String): List<AgendaItem> {
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                AgendaItem(
                    o.optString("title", ""),
                    o.optString("detail", ""),
                    o.optString("colorHex", "AAAAAA"),
                    o.optString("dateLabel", ""),
                    o.optString("time", ""),
                    o.optString("gcDate", ""),
                    o.optInt("scrollMin", 0))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun parseColorSafe(hex: String): Int {
        return try {
            Color.parseColor("#" + hex.trimStart('#'))
        } catch (e: Exception) {
            Color.parseColor("#AAAAAA")
        }
    }
}
