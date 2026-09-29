package com.rochwidias.notedhealth

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/// Widget home screen NotedHealth: ringkasan berat + ring skor/streak +
/// kebiasaan hari ini + tombol catat cepat. Data diisi Flutter
/// (refreshWeightWidget) ke SharedPreferences home_widget "HomeWidgetPreferences".
class WeightWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val data = HomeWidgetPlugin.getData(context)
        // Refresh snapshot periodik ≥10 menit; anti-loop karena callback
        // menulis w_updated sebelum memicu update widget lagi.
        WidgetRefresh.maybeRefresh(context, data)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, render(context, data))
        }
    }

    private fun render(context: Context, data: SharedPreferences): RemoteViews {
        val str = { key: String -> data.getString(key, "") ?: "" }
        val views = RemoteViews(context.packageName, R.layout.widget_weight)

        views.setTextViewText(R.id.w_date, str("w_date"))
        views.setTextViewText(R.id.w_action_btn, str("w_action"))
        views.setTextViewText(R.id.w_action_btn2, str("w_action2"))

        val hasData = str("w_has_data") == "1"
        views.setViewVisibility(R.id.widget_content, if (hasData) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_empty, if (hasData) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.w_empty, str("w_empty_text"))

        if (hasData) {
            views.setTextViewText(R.id.w_weight_label, str("w_weight_label"))
            views.setTextViewText(R.id.w_weight, str("w_text"))
            WidgetUi.applyDeltaPill(context, views, R.id.w_delta_pill, str("w_delta"))

            val caption = str("w_target_caption")
            views.setTextViewText(R.id.w_target_line, caption)
            views.setViewVisibility(
                R.id.w_target_line,
                if (caption.isEmpty()) View.GONE else View.VISIBLE,
            )

            views.setTextViewText(R.id.w_streak_label, str("w_streak_label"))
            WidgetUi.applyStreakBig(views, R.id.w_streak_big, str("w_streak"))
            val score = str("w_score").toIntOrNull() ?: 0
            views.setProgressBar(R.id.w_score_bar, 100, score.coerceIn(0, 100), false)
            views.setTextViewText(R.id.w_score_text, str("w_score_text"))
            views.setTextViewText(R.id.w_habit_progress, str("w_habit_progress"))
            val lines = str("w_habit_lines")
            views.setTextViewText(R.id.w_habit_lines, lines)
            views.setViewVisibility(
                R.id.w_habit_lines,
                if (lines.isEmpty()) View.GONE else View.VISIBLE,
            )
        }

        val openIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/open"),
        )
        views.setOnClickPendingIntent(R.id.widget_root, openIntent)

        val logIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/log_weight"),
        )
        views.setOnClickPendingIntent(R.id.w_action_btn, logIntent)

        val habitIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/habit"),
        )
        views.setOnClickPendingIntent(R.id.w_action_btn2, habitIntent)
        views.setOnClickPendingIntent(R.id.w_habit_progress, habitIntent)
        views.setOnClickPendingIntent(R.id.w_habit_lines, habitIntent)
        views.setOnClickPendingIntent(R.id.zone_habit, habitIntent)
        views.setOnClickPendingIntent(R.id.zone_streak, habitIntent)

        val weightZoneIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/open_weight"),
        )
        views.setOnClickPendingIntent(R.id.zone_weight, weightZoneIntent)
        return views
    }
}
