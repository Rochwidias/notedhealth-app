import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/i18n/app_localizations.dart';
import '../../models/habit.dart';
import '../../models/weight_entry.dart';
import '../habits/daily_log_store.dart';

/// Kunci data widget home screen — dibaca WeightWidgetProvider.kt
/// dari SharedPreferences ("HomeWidgetPreferences") yang diisi home_widget.
const String kwText = 'w_text';
const String kwDelta = 'w_delta';
const String kwTarget = 'w_target';
const String kwTargetCaption = 'w_target_caption';
const String kwScore = 'w_score';
const String kwScoreLabel = 'w_score_label';
const String kwStreak = 'w_streak';
const String kwStreakLabel = 'w_streak_label';
const String kwWeightLabel = 'w_weight_label';
const String kwScoreText = 'w_score_text';
const String kwHabitProgress = 'w_habit_progress';
const String kwHabitLines = 'w_habit_lines';
const String kwAction = 'w_action';
const String kwAction2 = 'w_action2';
const String kwDate = 'w_date';
const String kwHasData = 'w_has_data';
const String kwEmptyText = 'w_empty_text';
const String kwUpdated = 'w_updated';

/// Susun snapshot data untuk widget. Fungsi murni — dipanggil dari app
/// (setelah data berubah) maupun dari background callback (periodik).
Map<String, String> buildWidgetSnapshot({
  required Iterable<WeightEntry> weights,
  required Iterable<Habit> habits,
  required Map<String, bool> completions,
  required double? targetKg,
  String lang = 'id',
  DateTime? now,
}) {
  final ts = (now ?? DateTime.now()).millisecondsSinceEpoch.toString();
  final locale = lang == 'en' ? 'en_US' : 'id_ID';
  final dateStr = _fmtDate(now ?? DateTime.now(), locale);

  final sorted = weights.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final latest = sorted.isEmpty ? null : sorted.first;
  final prev = sorted.length > 1 ? sorted[1] : null;

  final active = habits.where((h) => h.active).toList();
  final score = calcScore(habits.toList(), completions).round();
  final streak = calcStreak();

  final doneCount = active.where((h) => completions[h.id] == true).length;
  final lines = <String>[];
  for (final h in active) {
    if (lines.length >= 3) break;
    final mark = completions[h.id] == true ? '✓' : '○';
    lines.add('$mark ${h.title}');
  }

  final doneLabels = <String>[
    trLang(lang, 'Berat'),
    trLang(lang, 'Streak'),
    trLang(lang, 'SKOR HARIAN'),
    trLang(lang, 'Skor harian'),
    trLang(lang, 'hari'),
    trLang(lang, '{a} dari {b} habit'),
    trLang(lang, 'Catat berat'),
    trLang(lang, 'Buka Habit'),
  ];
  // ponytail: snapshot harus membawa label terjemahan agar RemoteViews
  // tak perlu akses kamus; ceiling = gunakan label langsung di Kotlin.
  assert(doneLabels.every((e) => e.isNotEmpty));
  final hasData = latest != null;
  final targetLine = targetKg == null
      ? ''
      : 'Target ${fmtKg(targetKg, lang: lang)} kg';
  return {
    kwUpdated: ts,
    kwHasData: hasData ? '1' : '0',
    kwDate: dateStr,
    kwAction: trLang(lang, 'Catat berat'),
    kwAction2: trLang(lang, 'Buka Habit'),
    kwScoreLabel: trLang(lang, 'SKOR HARIAN'),
    kwStreakLabel: trLang(lang, 'Streak'),
    kwWeightLabel: trLang(lang, 'Berat'),
    kwScore: '$score',
    kwScoreText:
        '${trLang(lang, 'Skor harian')} $score/100',
    kwStreak: '🔥 $streak',
    kwHabitProgress:
        '${trLang(lang, '{a} dari {b} habit').replaceAll('{a}', '$doneCount').replaceAll('{b}', '${active.length}').toUpperCase()} · 🔥 $streak ${trLang(lang, 'hari').toUpperCase()}',
    kwHabitLines: lines.join('\n'),
    kwEmptyText: trLang(lang, 'Belum ada catatan'),
    if (hasData) ...{
      kwText: '${fmtKg(latest.valueKg, lang: lang)} kg',
      kwDelta: prev == null
          ? ''
          : '${_deltaSign(latest.valueKg - prev.valueKg)} '
              '${fmtKg((latest.valueKg - prev.valueKg).abs(), lang: lang)} kg',
      kwTarget: targetLine,
      kwTargetCaption: targetKg == null
          ? ''
          : '$targetLine · ${targetCaption(latest.valueKg, targetKg, lang: lang)}',
    } else ...{
      kwText: '',
      kwDelta: '',
      kwTarget: targetLine,
      kwTargetCaption: '',
    },
  };
}

String _deltaSign(double d) {
  if (d == 0) return '=';
  return d < 0 ? '↓' : '↑';
}

String _fmtDate(DateTime d, String locale) {
  try {
    return DateFormat('d MMM yyyy', locale).format(d);
  } catch (_) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
