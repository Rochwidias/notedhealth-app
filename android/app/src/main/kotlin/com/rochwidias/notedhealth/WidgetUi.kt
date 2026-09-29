package com.rochwidias.notedhealth

import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.View
import android.widget.RemoteViews

/// Gambar + warna bersama ketiga widget. Warna night dipilih manual
/// karena bitmap ring tak ikut qualifier values-night otomatis.
object WidgetUi {
    fun isNight(context: Context): Boolean =
        (context.resources.configuration.uiMode and
            Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

    /// Bitmap cincin skor 76dp: track penuh + busur progres ungu.
    fun scoreRing(context: Context, score: Int): Bitmap {
        val d = context.resources.displayMetrics.density
        val size = (76 * d + 0.5f).toInt().coerceAtLeast(1)
        val stroke = 8 * d
        val night = isNight(context)
        val track = Color.parseColor(if (night) "#3A3150" else "#E4DEFF")
        val prog = Color.parseColor(if (night) "#9D86FF" else "#7C5CFF")
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val oval = RectF(stroke / 2, stroke / 2, size - stroke / 2, size - stroke / 2)
        val p = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }
        p.color = track
        c.drawArc(oval, 0f, 360f, false, p)
        p.color = prog
        c.drawArc(oval, -90f, score.coerceIn(0, 100) / 100f * 360f, false, p)
        return bmp
    }

    /// Pil delta: ↓ hijau, ↑ merah, = ungu netral. Kosong → GONE.
    fun applyDeltaPill(context: Context, views: RemoteViews, viewId: Int, delta: String) {
        if (delta.isEmpty()) {
            views.setViewVisibility(viewId, View.GONE)
            return
        }
        views.setViewVisibility(viewId, View.VISIBLE)
        views.setTextViewText(viewId, delta)
        val night = isNight(context)
        val (bg, fg) = when (delta.firstOrNull()) {
            '↓' -> R.drawable.widget_pill_down to
                if (night) "#4FD6A0" else "#0E6B47"
            '↑' -> R.drawable.widget_pill_up to
                if (night) "#FF8A8F" else "#D13A40"
            else -> R.drawable.widget_pill_target to
                if (night) "#B7A6FF" else "#5638DB"
        }
        views.setInt(viewId, "setBackgroundResource", bg)
        views.setTextColor(viewId, Color.parseColor(fg))
    }

    /// "🔥 6" (sudah ber-emoji dari snapshot). Kosong → GONE.
    /// Alias lama applyStreak dipertahankan untuk provider yang belum migrasi.
    fun applyStreak(views: RemoteViews, viewId: Int, streak: String) {
        applyStreakBig(views, viewId, streak)
    }

    /// "🔥 6" besar untuk kolom streak (sudah ber-emoji dari snapshot).
    /// Kosong → GONE.
    fun applyStreakBig(views: RemoteViews, viewId: Int, streak: String) {
        if (streak.isEmpty()) {
            views.setViewVisibility(viewId, View.GONE)
            return
        }
        views.setViewVisibility(viewId, View.VISIBLE)
        views.setTextViewText(viewId, streak)
    }

    /// Pil target: teks sudah "Target 72 kg · kurang 2,0 kg". Kosong → GONE.
    fun applyTargetLine(views: RemoteViews, viewId: Int, line: String) {
        if (line.isEmpty()) {
            views.setViewVisibility(viewId, View.GONE)
            return
        }
        views.setViewVisibility(viewId, View.VISIBLE)
        views.setTextViewText(viewId, line)
    }
}
