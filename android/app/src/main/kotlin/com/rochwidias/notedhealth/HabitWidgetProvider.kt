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

/// Widget Habit/Streak (2x2): ring skor + chip streak + progres kebiasaan
/// + tombol buka checklist. Membaca snapshot yang sama dengan provider lain.
class HabitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val data = HomeWidgetPlugin.getData(context)
        WidgetRefresh.maybeRefresh(context, data)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, render(context, data))
        }
    }

    private fun render(context: Context, data: SharedPreferences): RemoteViews {
        val str = { key: String -> data.getString(key, "") ?: "" }
        val views = RemoteViews(context.packageName, R.layout.widget_habit)

        val score = str("w_score").toIntOrNull() ?: 0
        views.setTextViewText(R.id.w_score, score.toString())
        views.setImageViewBitmap(R.id.w_score_ring, WidgetUi.scoreRing(context, score))
        views.setTextViewText(R.id.w_score_label, str("w_score_label"))
        WidgetUi.applyStreak(views, R.id.w_streak, str("w_streak"))
        views.setTextViewText(R.id.w_habit_progress, str("w_habit_progress"))

        val lines = str("w_habit_lines")
        views.setTextViewText(R.id.w_habit_lines, lines)
        views.setViewVisibility(
            R.id.w_habit_lines,
            if (lines.isEmpty()) View.GONE else View.VISIBLE,
        )

        views.setTextViewText(R.id.w_action_btn, str("w_action2"))

        val habitIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/habit"),
        )
        views.setOnClickPendingIntent(R.id.habit_root, habitIntent)
        views.setOnClickPendingIntent(R.id.w_action_btn, habitIntent)
        return views
    }
}
