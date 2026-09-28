import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';
import '../../models/habit.dart';
import '../widget/weight_widget_service.dart';

const _habitBox = 'habits';

/// Daftar habit dari box Hive `habits` (mode Tamu).
/// Nanti jalur Google menembak Firestore dengan model yang sama.
final habitListProvider =
    NotifierProvider<HabitListController, List<Habit>>(HabitListController.new);

/// Habit aktif saja, untuk skor & checklist.
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitListProvider).where((h) => h.active).toList();
});

class HabitListController extends Notifier<List<Habit>> {
  Box get _box => Hive.box(_habitBox);

  @override
  List<Habit> build() => _all();

  List<Habit> _all() {
    final items = <Habit>[];
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is Map) items.add(Habit.fromMap(key.toString(), v));
    }
    items.sort((a, b) {
      final ca = a.createdAt ?? DateTime(2000);
      final cb = b.createdAt ?? DateTime(2000);
      return ca.compareTo(cb);
    });
    return items;
  }

  void _emit() {
    state = _all();
    unawaited(refreshWeightWidget());
  }

  Future<void> add({
    required String title,
    required String category,
    required int weight,
    String? icon,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final habit = Habit(
      id: id,
      title: title,
      category: category,
      weight: weight,
      active: true,
      icon: icon,
      createdAt: DateTime.now(),
    );
    detachHive(_box.put(id, habit.toMap()), 'habits/add');
    _emit();
  }

  Future<void> update(Habit habit) async {
    detachHive(_box.put(habit.id, habit.toMap()), 'habits/update');
    _emit();
  }

  Future<void> setActive(String id, bool value) async {
    final v = _box.get(id);
    if (v is! Map) return;
    final habit =
        Habit.fromMap(id, v).copyWith(active: value);
    detachHive(_box.put(id, habit.toMap()), 'habits/setActive');
    _emit();
  }

  Future<void> remove(String id) async {
    detachHive(_box.delete(id), 'habits/remove');
    _emit();
  }
}
