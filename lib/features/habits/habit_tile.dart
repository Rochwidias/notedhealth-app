import 'package:flutter/material.dart';

import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../widgets/ico_chip.dart';
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

IcoTone categoryTone(String c) => switch (c) {
      'kesehatan' => IcoTone.green,
      'belajar' => IcoTone.violet,
      _ => IcoTone.red,
    };

/// Isi baris meta: 'category' (Beranda) atau 'progress' (Checklist).
enum HabitMeta { category, progress }

/// Satu baris habit ala mockup `.habit`: check + chip ikon + judul + meta.
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.done,
    required this.onToggle,
    this.onTap,
    this.meta = HabitMeta.category,
  });

  final Habit habit;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final HabitMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final successSoft =
        isDark ? AppColors.successSoftDark : AppColors.successSoftLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: done ? successSoft : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: done ? Colors.transparent : theme.colorScheme.outline,
          ),
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
        child: Row(
          children: [
            _CheckButton(done: done, onTap: onToggle),
            const SizedBox(width: 13),
            IcoChip(
              icon: categoryIcon(habit.category),
              tone: categoryTone(habit.category),
              emoji: habit.icon,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(14.7,
                        color: done ? success : text,
                        weight: FontWeight.w800,
                        height: 1.25).copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accentSoftDark
                              : AppColors.accentSoftLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'bobot ${habit.weight}',
                          style: AppText.body(12.48,
                              color: isDark
                                  ? AppColors.accent
                                  : AppColors.amberTextLight,
                              weight: FontWeight.w800,
                              height: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (meta == HabitMeta.progress)
                        done
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: successSoft,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '+${habit.weight} poin',
                                  style: AppText.body(11.84,
                                      color: success,
                                      weight: FontWeight.w800,
                                      height: 1),
                                ),
                              )
                            : Text(tr(context, 'Belum selesai'),
                                style: AppText.body(11.5,
                                    color: muted, height: 1.2))
                      else
                        Text(tr(context, categoryLabel(habit.category)),
                            style: AppText.body(12.16,
                                color: muted, height: 1.2)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak centang 28×28 radius 10 ala mockup.
class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: done ? success : Colors.transparent,
          border: Border.all(
            color: done
                ? success
                : (isDark ? AppColors.darkSurface3 : AppColors.lightSurface3),
            width: 2.5,
          ),
        ),
        child: done
            ? const Center(
                child: SvgIcon('i-check', size: 15, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
