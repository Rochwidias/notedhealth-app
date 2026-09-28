package com.rochwidias.notedhealth

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/// Widget home screen NotedHealth: ringkasan berat + skor/streak +
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
        val updated = data.getString("w_updated", null)?.toLongOrNull() ?: 0L
        if (System.currentTimeMillis() - updated > REFRESH_INTERVAL_MS) {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("notedhealth://widget/refresh"),
            )
        }
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, render(context, data))
        }
    }

    private fun render(context: Context, data: SharedPreferences): RemoteViews {
        val str = { key: String -> data.getString(key, "") ?: "" }
        val views = RemoteViews(context.packageName, R.layout.widget_weight)

        views.setTextViewText(R.id.w_date, str("w_date"))
        views.setTextViewText(R.id.w_action_btn, str("w_action"))

        val hasData = str("w_has_data") == "1"
        views.setViewVisibility(R.id.widget_content, if (hasData) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_empty, if (hasData) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.w_empty, str("w_empty_text"))

        if (hasData) {
            views.setTextViewText(R.id.w_weight, str("w_text"))
            views.setTextViewText(R.id.w_delta, str("w_delta"))

            val target = str("w_target")
            val caption = str("w_target_caption")
            val targetLine = when {
                target.isEmpty() -> ""
                caption.isEmpty() -> "Target $target"
                else -> "Target $target · $caption"
            }
            views.setTextViewText(R.id.w_target, targetLine)
            views.setViewVisibility(
                R.id.w_target,
                if (targetLine.isEmpty()) View.GONE else View.VISIBLE,
            )

            val score = str("w_score").toIntOrNull() ?: 0
            views.setTextViewText(R.id.w_score, score.toString())
            views.setProgressBar(R.id.w_score_bar, 100, score.coerceIn(0, 100), false)

            views.setTextViewText(R.id.w_streak, str("w_streak"))
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
        return views
    }

    companion object {
        private const val REFRESH_INTERVAL_MS = 10 * 60 * 1000L
    }
}
