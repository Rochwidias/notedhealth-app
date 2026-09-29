import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../models/habit.dart';
import '../../models/weight_entry.dart';
import 'widget_snapshot.dart';

/// Nama AppWidgetProvider di AndroidManifest (ringkasan, berat, habit).
const List<String> _widgetProviders = [
  'WeightWidgetProvider',
  'WeightMiniWidgetProvider',
  'HabitWidgetProvider',
];

/// URI deep link dari widget → app.
final Uri widgetLogWeightUri = Uri.parse('notedhealth://widget/log_weight');
final Uri widgetRefreshUri = Uri.parse('notedhealth://widget/refresh');

/// Segarkan widget home screen dari isi box Hive yang sudah terbuka.
/// Aman dipanggil dari app (root isolate) setelah data berubah.
Future<void> refreshWeightWidget() async {
  try {
    final prefs = Hive.box('prefs');
    final lang = (prefs.get('lang') as String?) ?? 'id';
    final target = prefs.get('targetKg');
    final weightsBox = Hive.box('weights');
    final weights = <WeightEntry>[];
    for (final key in weightsBox.keys) {
      final v = weightsBox.get(key);
      if (v is Map) weights.add(WeightEntry.fromMap(key.toString(), v));
    }
    final habitsBox = Hive.box('habits');
    final habits = <Habit>[];
    for (final key in habitsBox.keys) {
      final v = habitsBox.get(key);
      if (v is Map) habits.add(Habit.fromMap(key.toString(), v));
    }
    final today = DateTime.now();
    final dateKey =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final logRaw = Hive.box('daily_logs').get(dateKey);
    final completions = <String, bool>{};
    if (logRaw is Map && logRaw['completions'] is Map) {
      (logRaw['completions'] as Map).forEach((k, v) {
        if (v is bool) completions[k.toString()] = v;
      });
    }

    final snap = buildWidgetSnapshot(
      weights: weights,
      habits: habits,
      completions: completions,
      targetKg: target is num ? target.toDouble() : null,
      lang: lang,
    );
    for (final e in snap.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, e.value);
    }
    for (final name in _widgetProviders) {
      await HomeWidget.updateWidget(name: name);
    }
  } catch (_) {
    // Widget memakai data terakhir yang tersimpan — gagal refresh tak fatal.
  }
}

/// Callback yang dipanggil native (HomeWidgetBackgroundIntent.getBroadcast)
/// saat widget minta refresh periodik (onUpdate → setiap ≥10 menit).
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? data) async {
  if (data == null || data.path != '/refresh') return;
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await Hive.openBox('session');
    await Hive.openBox('habits');
    await Hive.openBox('weights');
    await Hive.openBox('daily_logs');
    await Hive.openBox('prefs');
    await Hive.openBox('favorites');
  } catch (_) {
    return;
  }
  await refreshWeightWidget();
}
