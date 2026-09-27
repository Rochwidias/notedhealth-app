import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../widgets/svg_icon.dart';

String categoryLabel(String c) => switch (c) {
      'kesehatan' => 'Kesehatan',
      'belajar' => 'Belajar',
      _ => 'Lainnya',
    };

String categoryIcon(String c) => switch (c) {
      'kesehatan' => 'i-leaf',
      'belajar' => 'i-book',
      _ => 'i-dots',
    };

/// Satu baris habit + tombol centang (dipakai Beranda & Checklist).
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.done,
    required this.onToggle,
    this.onTap,
    this.showStreak,
  });

  final Habit habit;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final int? showStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final line = theme.colorScheme.outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: habit.icon != null && habit.icon!.isNotEmpty
              ? Text(habit.icon!, style: const TextStyle(fontSize: 22))
              : SvgIcon(
                  categoryIcon(habit.category),
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
        ),
        title: Text(
          habit.title,
          style: AppText.body(14, color: text, weight: FontWeight.w700),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              categoryLabel(habit.category),
              style: AppText.body(11.5, color: muted),
            ),
            Text('  ·  +${habit.weight} poin',
                style: AppText.body(11.5, color: muted)),
            if (showStreak != null && showStreak! > 1)
              Text('  ·  🔥$showStreak',
                  style: AppText.body(11.5, color: muted)),
          ],
        ),
        trailing: _CheckButton(done: done, onTap: onToggle),
      ),
    );
  }
}

/// Lingkaran centang ala mockup.
class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? scheme.primary : Colors.transparent,
          border: Border.all(
            color: done ? scheme.primary : scheme.outline,
            width: 2.5,
          ),
        ),
        child: done
            ? SvgIcon('i-check', size: 15, color: Colors.white)
            : null,
      ),
    );
  }
}
