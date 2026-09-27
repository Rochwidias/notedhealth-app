import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/score_ring.dart';
import '../../widgets/svg_icon.dart';
import '../habits/daily_log_store.dart';
import '../habits/habit_repository.dart';
import '../habits/habit_tile.dart';
import '../profile/prefs_store.dart';
import '../weight/weight_repository.dart';
import '../weight/weight_sheet.dart';

/// Beranda — frame 02 mockup: skor, streak, berat, target, habit hari ini.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    final prefs = ref.watch(prefsProvider);
    final habits = ref.watch(activeHabitsProvider);
    final completions = ref.watch(completionsProvider);
    final score = ref.watch(todayScoreProvider);
    final streak = ref.watch(streakProvider);
    final latest = ref.watch(latestWeightProvider);

    final firstName =
        prefs.name.isEmpty ? 'Teman Sehat' : prefs.name.split(' ').first;
    final dateStr =
        DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());
    final doneCount = habits.where((h) => completions[h.id] == true).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, $firstName 👋',
                            style: AppText.display(22, color: text)),
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: AppText.body(12.5, color: muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Pengingat aktif 07:00 & 21:00 — atur di Profil.'),
                        ),
                      );
                    },
                    icon: SvgIcon('i-bell', size: 22, color: text),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Kartu skor.
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    ScoreRing(score: score),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKOR HARI INI',
                              style: AppText.body(11,
                                  color: Colors.white70,
                                  weight: FontWeight.w800)),
                          Text('$doneCount dari ${habits.length} habit',
                              style: AppText.body(13.5,
                                  color: Colors.white,
                                  weight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('🔥 $streak hari beruntun',
                                style: AppText.body(12,
                                    color: Colors.white,
                                    weight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Streak + berat.
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: 'i-sparkle',
                      title: '$streak hari',
                      subtitle: 'Streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: 'i-scale',
                      title: latest == null
                          ? '—'
                          : '${fmtKg(latest.valueKg)} kg',
                      subtitle: latest == null
                          ? 'Belum timbang'
                          : 'Timbangan terakhir',
                      onTap: () => context.go('/weight'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Strip target.
              if (prefs.targetKg != null && latest != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '🎯 Target ${fmtKg(prefs.targetKg!)} kg · '
                    '${targetCaption(latest.valueKg, prefs.targetKg!)}',
                    style: AppText.body(13,
                        color: theme.colorScheme.onPrimaryContainer,
                        weight: FontWeight.w700),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Atur target berat di Profil'),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text('Habit hari ini',
                        style: AppText.display(17, color: text)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/checklist'),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (habits.isEmpty)
                _EmptyHabitsCard(onAdd: () => context.push('/habit-form'))
              else
                for (final habit in habits.take(4))
                  HabitTile(
                    habit: habit,
                    done: completions[habit.id] ?? false,
                    onToggle: () => ref
                        .read(completionsProvider.notifier)
                        .toggle(habit.id, habits),
                    onTap: () =>
                        context.push('/habit-form?id=${habit.id}'),
                  ),
              const SizedBox(height: 14),
              // Katalog sehat.
              GestureDetector(
                onTap: () => context.push('/catalog'),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/food/food-salad.jpg',
                        width: 96,
                        height: 84,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Katalog sehat',
                                style: AppText.body(14.5,
                                    color: text,
                                    weight: FontWeight.w800)),
                            Text('12 menu makan & minum',
                                style: AppText.body(12, color: muted)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SvgIcon('i-next', size: 20, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const _QuickFab(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgIcon(icon,
                size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title,
                style: AppText.display(19,
                    color: theme.colorScheme.onSurface)),
            Text(subtitle,
                style: AppText.body(11.5,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  const _EmptyHabitsCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text('Belum ada habit',
              style: AppText.body(15,
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Mulai dari 1 kebiasaan kecil hari ini.',
              style: AppText.body(12.5,
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAdd,
            child: const Text('+ Tambah habit pertama'),
          ),
        ],
      ),
    );
  }
}

/// FAB menu aksi cepat ala mockup frame 03.
class _QuickFab extends StatefulWidget {
  const _QuickFab();

  @override
  State<_QuickFab> createState() => _QuickFabState();
}

class _QuickFabState extends State<_QuickFab> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _FabAction(
            icon: 'i-scale',
            label: 'Catat berat',
            onTap: () {
              setState(() => _open = false);
              showWeightSheet(context);
            },
          ),
          const SizedBox(height: 10),
          _FabAction(
            icon: 'i-list',
            label: 'Checklist',
            onTap: () {
              setState(() => _open = false);
              context.go('/checklist');
            },
          ),
          const SizedBox(height: 10),
          _FabAction(
            icon: 'i-plus',
            label: 'Tambah habit',
            onTap: () {
              setState(() => _open = false);
              context.push('/habit-form');
            },
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          onPressed: () => setState(() => _open = !_open),
          child: Transform.rotate(
            angle: _open ? 0.785 : 0,
            child: SvgIcon('i-plus', size: 24, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FabAction extends StatelessWidget {
  const _FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(icon,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(label,
                style: AppText.body(13,
                    color: theme.colorScheme.onSurface,
                    weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
