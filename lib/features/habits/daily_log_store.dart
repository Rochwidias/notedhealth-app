import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';
import '../../models/daily_log.dart';
import '../../models/habit.dart';
import 'habit_repository.dart';

/// Kunci tanggal YYYY-MM-DD.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Skor harian = Σ bobot selesai ÷ Σ bobot aktif × 100.
double calcScore(List<Habit> habits, Map<String, bool> completions) {
  final active = habits.where((h) => h.active).toList();
  final total = active.fold<int>(0, (s, h) => s + h.weight);
  if (total == 0) return 0;
  final done = active
      .where((h) => completions[h.id] == true)
      .fold<int>(0, (s, h) => s + h.weight);
  return done / total * 100;
}

/// Centang hari ini (habitId -> done), tersimpan di box `daily_logs`.
final completionsProvider =
    NotifierProvider<CompletionsController, Map<String, bool>>(
        CompletionsController.new);

/// Skor hari ini 0–100.
final todayScoreProvider = Provider<double>((ref) {
  final habits = ref.watch(habitListProvider);
  final completions = ref.watch(completionsProvider);
  return calcScore(habits, completions);
});

/// Streak global: hari berturut-turut dengan skor > 0.
final streakProvider = Provider<int>((ref) {
  ref.watch(completionsProvider);
  return calcStreak();
});

class CompletionsController extends Notifier<Map<String, bool>> {
  Box get _box => Hive.box('daily_logs');

  String get _today => dateKey(DateTime.now());

  @override
  Map<String, bool> build() => _read(_today).completions;

  DailyLog _read(String date) {
    final v = _box.get(date);
    if (v is! Map) return DailyLog(date: date, completions: {}, score: 0);
    return DailyLog.fromMap(date, v);
  }

  Future<void> toggle(String habitId, List<Habit> habits) async {
    final cur = Map<String, bool>.from(state);
    cur[habitId] = !(cur[habitId] ?? false);
    final score = calcScore(habits, cur);
    detachHive(_box.put(_today, {'completions': cur, 'score': score}), 'daily_log');
    state = cur;
  }
}

/// Hitung streak global langsung dari box (tanpa Riverpod, bisa dipakai ulang).
int calcStreak() {
  if (!Hive.isBoxOpen('daily_logs')) return 0;
  final box = Hive.box('daily_logs');
  double scoreOf(DateTime d) {
    final v = box.get(dateKey(d));
    if (v is! Map) return 0;
    return ((v['score'] ?? 0) as num).toDouble();
  }

  var day = DateTime.now();
  // Hari ini boleh kosong — streak dihitung dari kemarin.
  if (scoreOf(day) <= 0) {
    day = day.subtract(const Duration(days: 1));
  }
  var streak = 0;
  for (var i = 0; i < 365; i++) {
    if (scoreOf(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

/// Streak satu habit: hari berturut-turut habit itu dicentang.
int habitStreak(String habitId) {
  if (!Hive.isBoxOpen('daily_logs')) return 0;
  final box = Hive.box('daily_logs');
  bool doneOn(DateTime d) {
    final v = box.get(dateKey(d));
    if (v is! Map) return false;
    final raw = v['completions'];
    if (raw is! Map) return false;
    return (raw[habitId] as bool?) ?? false;
  }

  var day = DateTime.now();
  if (!doneOn(day)) day = day.subtract(const Duration(days: 1));
  var streak = 0;
  for (var i = 0; i < 365; i++) {
    if (doneOn(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}
