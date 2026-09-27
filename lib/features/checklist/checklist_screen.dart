import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../widgets/svg_icon.dart';
import '../habits/daily_log_store.dart';
import '../habits/habit_repository.dart';
import '../habits/habit_tile.dart';

/// Checklist harian — frame 04 mockup.
class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    final all = ref.watch(habitListProvider);
    final habits = all.where((h) => h.active).toList();
    final completions = ref.watch(completionsProvider);
    final score = ref.watch(todayScoreProvider);
    final doneCount =
        habits.where((h) => completions[h.id] == true).length;

    return Scaffold(
      body: SafeArea(
        child: habits.isEmpty
            ? _EmptyChecklist(onAdd: () => context.push('/habit-form'))
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Checklist hari ini',
                        style: AppText.display(22, color: text)),
                    const SizedBox(height: 4),
                    Text('$doneCount dari ${habits.length} selesai',
                        style: AppText.body(13, color: muted)),
                    const SizedBox(height: 12),
                    _ProgressBar(score: score),
                    const SizedBox(height: 16),
                    for (final group in _groups(habits)) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8),
                        child: Text(
                          categoryLabel(group.$1),
                          style: AppText.body(12.5,
                              color: muted,
                              weight: FontWeight.w800),
                        ),
                      ),
                      for (final habit in group.$2)
                        HabitTile(
                          habit: habit,
                          done: completions[habit.id] ?? false,
                          onToggle: () => ref
                              .read(completionsProvider.notifier)
                              .toggle(habit.id, habits),
                          onTap: () => context
                              .push('/habit-form?id=${habit.id}'),
                          showStreak: habitStreak(habit.id),
                        ),
                    ],
                    if (all.any((h) => !h.active)) ...[
                      const SizedBox(height: 8),
                      Text('Nonaktif (${all.where((h) => !h.active).length})',
                          style: AppText.body(12.5,
                              color: muted,
                              weight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      for (final habit
                          in all.where((h) => !h.active))
                        Opacity(
                          opacity: 0.6,
                          child: HabitTile(
                            habit: habit,
                            done: false,
                            onToggle: () {},
                            onTap: () => context.push(
                                '/habit-form?id=${habit.id}'),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/habit-form'),
        child: SvgIcon('i-plus', size: 24, color: Colors.white),
      ),
    );
  }
}

/// Kelompokkan habit aktif per kategori sesuai urutan mockup.
List<(String, List<Habit>)> _groups(List<Habit> habits) {
  const order = ['kesehatan', 'belajar', 'lainnya'];
  return [
    for (final c in order)
      (c, habits.where((h) => h.category == c).toList()),
  ].where((g) => g.$2.isNotEmpty).toList();
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (score / 100).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${score.round()}',
                style: AppText.display(20,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _EmptyChecklist extends StatelessWidget {
  const _EmptyChecklist({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon('i-list',
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text('Belum ada habit',
                style: AppText.display(19,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text(
              'Tambah kebiasaan pertamamu — skor harian dihitung dari bobot habit yang selesai.',
              textAlign: TextAlign.center,
              style: AppText.body(13,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text('+ Tambah habit'),
            ),
          ],
        ),
      ),
    );
  }
}
