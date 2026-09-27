import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
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
    final history = ref.watch(weightHistoryProvider);
    final latest = history.isEmpty ? null : history.first;
    final prev = history.length > 1 ? history[1] : null;

    final firstName =
        prefs.name.isEmpty ? 'Teman Sehat' : prefs.name.split(' ').first;
    final lang = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('EEEE, d MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID')
        .format(DateTime.now());
    final doneCount = habits.where((h) => completions[h.id] == true).length;

    final caption = habits.isEmpty
        ? tr(context, 'Belum ada habit hari ini — buat satu dulu ya.')
        : doneCount == habits.length
            ? tr(context,
                    'Semua habit selesai — skor {x}% dari total bobot aktif. Mantap!')
                .replaceAll('{x}', '$score')
            : tr(context, '{x}% dari total bobot aktif hari ini — tinggal {n} lagi!')
                .replaceAll('{x}', '$score')
                .replaceAll('{n}', '${habits.length - doneCount}');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Appbar ala mockup: avatar + salam + lonceng.
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      firstName.isEmpty ? 'N' : firstName.characters.first.toUpperCase(),
                      style: AppText.display(22,
                          color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            tr(context, 'Halo, {name} 👋')
                                .replaceAll('{name}', firstName),
                            style: AppText.body(15,
                                color: text, weight: FontWeight.w800,
                                height: 1.2)),
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: AppText.body(11.5, color: muted,
                                height: 1.3)),
                      ],
                    ),
                  ),
                  _BellButton(),
                ],
              ),
              const SizedBox(height: 14),
              // Kartu skor — gradient + lingkaran dekor ala mockup.
              Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryInkLight,
                      Color(0xFF8F74FF),
                      Color(0xFFB39BFF),
                    ],
                    stops: [0, 0.65, 1],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -50,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 46,
                      bottom: -60,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              AppColors.accent.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        ScoreRing(score: score),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr(context, 'SKOR HARIAN'),
                                  style: AppText.body(12.5,
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                      weight: FontWeight.w800,
                                      height: 1.2)),
                              const SizedBox(height: 4),
                              Text(
                                  tr(context, '{a} dari {b} habit')
                                      .replaceAll('{a}', '$doneCount')
                                      .replaceAll('{b}', '${habits.length}'),
                                  style: AppText.display(25.6,
                                      color: Colors.white)),
                              const SizedBox(height: 6),
                              Text(caption,
                                  style: AppText.body(13.5,
                                      color: Colors.white
                                          .withValues(alpha: 0.92),
                                      height: 1.35)),
                            ],
                          ),
                        ),
                      ],
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
                      emoji: '🔥',
                      label: tr(context, 'Streak'),
                      big: tr(context, '{x} hari').replaceAll('{x}', '$streak'),
                      sub: tr(context, 'berturut-turut'),
                      subColor: theme.brightness == Brightness.dark
                          ? AppColors.successDark
                          : AppColors.successLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: 'i-scale',
                      iconTone: IcoTone.violet,
                      label: tr(context, 'Berat terakhir'),
                      big: latest == null
                          ? '— kg'
                          : '${fmtKg(latest.valueKg, lang: lang)} kg',
                      sub: latest == null
                          ? tr(context, 'Belum timbang')
                          : prev == null
                              ? tr(context, 'catatan pertamamu')
                              : _deltaCaption(
                                  latest.valueKg, prev.valueKg, lang),
                      subColor: latest == null || prev == null
                          ? muted
                          : latest.valueKg <= prev.valueKg
                              ? (theme.brightness == Brightness.dark
                                  ? AppColors.successDark
                                  : AppColors.successLight)
                              : (theme.brightness == Brightness.dark
                                  ? AppColors.dangerDark
                                  : AppColors.dangerLight),
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
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IcoChip(icon: 'i-target', tone: IcoTone.violet),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'TARGET BERAT'),
                                style: AppText.body(12.16,
                                    color: theme
                                        .colorScheme.onPrimaryContainer,
                                    weight: FontWeight.w800,
                                    height: 1.2)),
                            const SizedBox(height: 2),
                            Text(
                              '${fmtKg(prefs.targetKg!, lang: lang)} kg — '
                              '${targetCaption(latest.valueKg, prefs.targetKg!, lang: lang)}',
                              style: AppText.display(20,
                                  color: theme
                                      .colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.successSoftDark
                              : AppColors.successSoftLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          _onTarget(latest.valueKg, prefs.targetKg!)
                              ? tr(context, 'Tepat jalur')
                              : tr(context, 'Menuju target'),
                          style: AppText.body(11.84,
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.successDark
                                  : AppColors.successLight,
                              weight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => context.go('/profile'),
                  child: Text(tr(context, 'Atur target berat di Profil')),
                ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: tr(context, 'Habit hari ini'),
                link: tr(context, 'Lihat semua'),
                onLink: () => context.go('/checklist'),
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
              // Menu sehat — dua row-btn ala mockup.
              _SectionHeader(title: tr(context, 'Menu sehat'),
                  link: tr(context, 'Katalog'),
                  onLink: () => context.push('/catalog')),
              const SizedBox(height: 6),
              _MenuRow(
                icon: 'i-leaf',
                tone: IcoTone.green,
                title: tr(context, 'Makanan Sehat'),
                desc: tr(context, '6 menu + kalori per porsi'),
                onTap: () => context.push('/catalog?tab=0'),
              ),
              const SizedBox(height: 10),
              _MenuRow(
                icon: 'i-droplet',
                tone: IcoTone.blue,
                title: tr(context, 'Minuman Sehat'),
                desc: tr(context, '6 minuman rendah kalori'),
                onTap: () => context.push('/catalog?tab=1'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const _QuickFab(),
    );
  }
}

String _deltaCaption(double now, double before, String lang) {
  final d = now - before;
  if (d == 0) return trLang(lang, 'tanpa perubahan');
  final sign = d < 0 ? '▼' : '▲';
  return '$sign ${trLang(lang, '{x} kg sejak catatan lalu').replaceAll('{x}', fmtKg(d.abs(), lang: lang))}';
}

bool _onTarget(double now, double target) => (now - target).abs() <= 2;

class _BellButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                tr(context, 'Pengingat aktif 07:00 & 21:00 — atur di Profil.')),
          ),
        );
      },
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: SvgIcon('i-bell', size: 20,
            color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.link, required this.onLink});

  final String title;
  final String link;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: AppText.body(16.32,
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: onLink,
          child: Text(link,
              style: AppText.body(13.12,
                  color: theme.colorScheme.primary,
                  weight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final String icon;
  final IcoTone tone;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFF1E1B2E).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            IcoChip(icon: icon, tone: tone),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.body(14.4,
                          color: theme.colorScheme.onSurface,
                          weight: FontWeight.w800,
                          height: 1.25)),
                  Text(desc,
                      style: AppText.body(12.16,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3)),
                ],
              ),
            ),
            SvgIcon('i-next', size: 20,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    this.icon,
    this.emoji,
    this.iconTone = IcoTone.amber,
    required this.label,
    required this.big,
    required this.sub,
    required this.subColor,
    this.onTap,
  });

  final String? icon;
  final String? emoji;
  final IcoTone iconTone;
  final String label;
  final String big;
  final String sub;
  final Color subColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFF1E1B2E).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IcoChip(
                  icon: icon ?? 'i-sparkle',
                  tone: iconTone,
                  emoji: emoji,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(12.16,
                          color: theme.colorScheme.onSurfaceVariant,
                          weight: FontWeight.w800,
                          height: 1.2)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(big,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(27.2,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 2),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(12.16,
                    color: subColor, weight: FontWeight.w700)),
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
          Text(tr(context, 'Belum ada habit'),
              style: AppText.body(15,
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(tr(context, 'Mulai dari 1 kebiasaan kecil hari ini.'),
              style: AppText.body(12.5,
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAdd,
            child: Text(tr(context, '+ Tambah habit pertama')),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _FabAction(
            icon: 'i-scale',
            label: tr(context, 'Catat berat'),
            onTap: () {
              setState(() => _open = false);
              showWeightSheet(context);
            },
          ),
          const SizedBox(height: 10),
          _FabAction(
            icon: 'i-list',
            label: tr(context, 'Centang habit'),
            onTap: () {
              setState(() => _open = false);
              context.go('/checklist');
            },
          ),
          const SizedBox(height: 10),
          _FabAction(
            icon: 'i-plus',
            label: tr(context, 'Tambah habit'),
            onTap: () {
              setState(() => _open = false);
              context.push('/habit-form');
            },
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
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
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : const Color(0xFF1E1B2E).withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primarySoftDark
                    : AppColors.primarySoftLight,
                shape: BoxShape.circle,
              ),
              child: SvgIcon(icon,
                  size: 16,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(label,
                style: AppText.body(13.5,
                    color: theme.colorScheme.onSurface,
                    weight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
