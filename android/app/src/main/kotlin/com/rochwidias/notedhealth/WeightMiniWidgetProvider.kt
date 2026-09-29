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

/// Widget Berat (4x1): berat terakhir + pil delta + caption target + tombol +.
/// Membaca snapshot yang sama dengan WeightWidgetProvider.
class WeightMiniWidgetProvider : AppWidgetProvider() {
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
        val views = RemoteViews(context.packageName, R.layout.widget_weight_mini)

        val hasData = str("w_has_data") == "1"
        views.setViewVisibility(R.id.mini_content, if (hasData) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.mini_empty, if (hasData) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.w_empty, str("w_empty_text"))

        if (hasData) {
            views.setTextViewText(R.id.w_weight, str("w_text"))
            WidgetUi.applyDeltaPill(context, views, R.id.w_delta_pill, str("w_delta"))

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
        }

        // Teks "+" statis dari layout — tidak ditimpa snapshot.

        val logIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/log_weight"),
        )
        views.setOnClickPendingIntent(R.id.w_action_btn, logIntent)

        val weightZoneIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("notedhealth://widget/open_weight"),
        )
        views.setOnClickPendingIntent(R.id.mini_root, weightZoneIntent)
        return views
    }
}
