package com.rochwidias.notedhealth

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/// Minta Flutter me-refresh snapshot widget bila data sudah ≥10 menit.
/// Dipakai bersama oleh semua WeightWidgetProvider — anti-loop karena
/// callback Flutter menulis w_updated sebelum memicu update widget.
object WidgetRefresh {
    private const val INTERVAL_MS = 10 * 60 * 1000L

    fun maybeRefresh(context: Context, data: SharedPreferences) {
        val updated = data.getString("w_updated", null)?.toLongOrNull() ?: 0L
        if (System.currentTimeMillis() - updated > INTERVAL_MS) {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("notedhealth://widget/refresh"),
            )
        }
    }
}
