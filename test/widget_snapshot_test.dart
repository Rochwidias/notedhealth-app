import 'package:flutter_test/flutter_test.dart';

import 'package:notedhealth/features/widget/widget_snapshot.dart';
import 'package:notedhealth/models/habit.dart';
import 'package:notedhealth/models/weight_entry.dart';

WeightEntry _w(double kg, String date) =>
    WeightEntry(id: date, valueKg: kg, date: date);

Habit _h(String id, String title, {int weight = 50, bool active = true}) =>
    Habit(
      id: id,
      title: title,
      category: 'kesehatan',
      weight: weight,
      active: active,
    );

void main() {
  final now = DateTime(2026, 8, 27, 9);

  Map<String, String> build({
    List<WeightEntry>? weights,
    List<Habit>? habits,
    Map<String, bool>? completions,
    double? targetKg,
    String lang = 'id',
  }) =>
      buildWidgetSnapshot(
        weights: weights ?? [_w(72, '2026-08-27'), _w(73.5, '2026-08-20')],
        habits: habits ?? [_h('h1', 'Olahraga'), _h('h2', 'Baca')],
        completions: completions ?? {'h1': true},
        targetKg: targetKg,
        lang: lang,
        now: now,
      );

  test('snapshot lengkap (id): kunci, berat, delta turun, target, skor',
      () {
    final s = build(targetKg: 68);

    expect(
      s.keys,
      containsAll(<String>[
        kwText,
        kwDelta,
        kwTarget,
        kwTargetCaption,
        kwScore,
        kwScoreLabel,
        kwStreak,
        kwStreakLabel,
        kwHabitProgress,
        kwHabitLines,
        kwAction,
        kwDate,
        kwHasData,
        kwEmptyText,
        kwUpdated,
      ]),
    );

    expect(s[kwHasData], '1');
    expect(s[kwText], '72,0 kg'); // koma utk id
    expect(s[kwDelta], '↓ 1,5 kg'); // 72 < 73.5 → turun
    expect(s[kwTarget], '68,0 kg');
    expect(s[kwTargetCaption], 'kurang 4,0 kg lagi');
    expect(s[kwAction], 'Catat berat');
    expect(s[kwScoreLabel], 'SKOR HARIAN');
    expect(s[kwScore], '50'); // satu habit 50 dari total bobot 100
    expect(s[kwHabitProgress], '1 dari 2 habit');
    expect(s[kwHabitLines], '✓ Olahraga\n○ Baca');
    expect(s[kwDate], contains('2026'));
    expect(s[kwUpdated], isNotEmpty);
    expect(int.parse(s[kwUpdated]!), greaterThan(0));
  });

  test('snapshot bahasa Inggris: titik desimal + label EN', () {
    final s = build(lang: 'en', targetKg: 68);

    expect(s[kwText], '72.0 kg'); // titik utk en
    expect(s[kwDelta], '↓ 1.5 kg');
    expect(s[kwAction], 'Log weight');
    expect(s[kwScoreLabel], 'DAILY SCORE');
    expect(s[kwStreakLabel], 'Streak');
    expect(s[kwHabitProgress], '1 of 2 habits');
    expect(s[kwEmptyText], 'No entries yet');
  });

  test('delta naik dan sama rata', () {
    final up = build(
      weights: [_w(75, '2026-08-27'), _w(73.5, '2026-08-20')],
    );
    expect(up[kwDelta], '↑ 1,5 kg');

    final flat = build(
      weights: [_w(73.5, '2026-08-27'), _w(73.5, '2026-08-20')],
    );
    expect(flat[kwDelta], '= 0,0 kg');
  });

  test('empty state: tanpa catatan berat', () {
    final s = build(weights: [], targetKg: 68);

    expect(s[kwHasData], '0');
    expect(s[kwText], '');
    expect(s[kwDelta], '');
    expect(s[kwTarget], '68,0 kg');
    expect(s[kwTargetCaption], '');
    expect(s[kwEmptyText], 'Belum ada catatan');
  });

  test('habit nonaktif dihitung keluar dari progres', () {
    final s = build(
      habits: [
        _h('h1', 'Olahraga'),
        _h('h2', 'Baca'),
        _h('h3', 'Meditasi', active: false),
      ],
      completions: {'h1': true, 'h3': true},
    );

    expect(s[kwHabitProgress], '1 dari 2 habit'); // h3 aktif=false
    expect(s[kwHabitLines], '✓ Olahraga\n○ Baca');
  });
}
