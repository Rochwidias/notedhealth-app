import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
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
    final muted = theme.colorScheme.onSurfaceVariant;

    final all = ref.watch(habitListProvider);
    final habits = all.where((h) => h.active).toList();
    final completions = ref.watch(completionsProvider);
    final score = ref.watch(todayScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Checklist Hari Ini')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(tr(context, 'Pilih tanggal — segera hadir.'))),
              ),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: SvgIcon('i-calendar', size: 20, color: theme.colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: habits.isEmpty
            ? _EmptyChecklist(onAdd: () => context.push('/habit-form'))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProgressCard(
                      score: score,
                      totalWeight: habits.fold<int>(
                          0, (sum, h) => sum + h.weight),
                    ),
                    const SizedBox(height: 8),
                    for (final group in _groups(habits)) ...[
                      _CatLabel(label: categoryLabel(group.$1)),
                      for (final habit in group.$2)
                        HabitTile(
                          habit: habit,
                          done: completions[habit.id] ?? false,
                          onToggle: () => ref
                              .read(completionsProvider.notifier)
                              .toggle(habit.id, habits),
                          onTap: () =>
                              context.push('/habit-form?id=${habit.id}'),
                          meta: HabitMeta.progress,
                        ),
                    ],
                    if (all.any((h) => !h.active)) ...[
                      _CatLabel(label: 'Nonaktif'),
                      for (final habit in all.where((h) => !h.active))
                        Opacity(
                          opacity: 0.6,
                          child: HabitTile(
                            habit: habit,
                            done: false,
                            onToggle: () {},
                            onTap: () => context
                                .push('/habit-form?id=${habit.id}'),
                            meta: HabitMeta.progress,
                          ),
                        ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      tr(context, 'Streak harianmu aman selama skor > 0'),
                      textAlign: TextAlign.center,
                      style: AppText.body(11.5, color: muted),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
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

/// Label kategori huruf besar + ikon ala mockup `.cat-label`.
class _CatLabel extends StatelessWidget {
  const _CatLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final c = switch (label) {
      'Kesehatan' => 'kesehatan',
      'Belajar' => 'belajar',
      _ => 'lainnya',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10, left: 2),
      child: Row(
        children: [
          SvgIcon(categoryIcon(c), size: 16, color: muted),
          const SizedBox(width: 7),
          Text(
            tr(context, label).toUpperCase(),
            style: AppText.body(12.48,
                color: muted,
                weight: FontWeight.w800,
                height: 1.2),
          ),
        ],
      ),
    );
  }
}

/// Kartu progres skor ala mockup: label + persen + bar + caption.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.score, required this.totalWeight});

  final double score;
  final int totalWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryInk = isDark
        ? AppColors.primary
        : AppColors.primaryInkLight;
    final pct = score.clamp(0.0, 100.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF1E1B2E).withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(tr(context, 'Progres skor'),
                    style: AppText.body(14.4,
                        color: theme.colorScheme.onSurface,
                        weight: FontWeight.w800)),
              ),
              Text('${pct.round()}%',
                  style: AppText.display(21.6, color: primaryInk)),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: isDark
                          ? AppColors.darkSurface3
                          : AppColors.lightSurface3,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct / 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFFA58BFF)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '${pct.round()} poin dari total bobot $totalWeight — '
            'selesai sebelum jam 23.00 ya!',
            style: AppText.body(11.5, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyChecklist extends StatelessWidget {
  const _EmptyChecklist({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryInk = isDark
        ? AppColors.primary
        : AppColors.primaryInkLight;
    final primarySoft = isDark
        ? AppColors.primarySoftDark
        : AppColors.primarySoftLight;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustrasi ala mockup: lingkaran putus + plus.
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                  ),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primarySoft,
                    ),
                    child: Center(
                      child: SvgIcon('i-plus', size: 40, color: primaryInk),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 14,
                    child: SvgIcon('i-sparkle', size: 22,
                        color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(tr(context, 'Belum ada habit'),
                textAlign: TextAlign.center,
                style: AppText.display(20.8,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              tr(context, 'Mulai dari satu kebiasaan kecil — bobotnya yang menentukan '
                  'seberapa penting bagi skor harianmu.'),
              textAlign: TextAlign.center,
              style: AppText.body(14.08,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdd,
                child: Text(tr(context, 'Buat habit pertama')),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr(context, 'Contoh: “Minum air 8 gelas · bobot 20”'),
              textAlign: TextAlign.center,
              style: AppText.body(11.5,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
