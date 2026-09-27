import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
import '../../widgets/svg_icon.dart';
import 'habit_repository.dart';
import 'habit_tile.dart';

/// 64 emoji mockup, dikelompokkan per label.
const List<(String, List<String>)> _emojiGroups = [
  ('Kesehatan & olahraga', [
    '💧', '🏃', '🚶', '🧘', '💪', '🏋️', '⚽', '🏀',
    '🚴', '🏐', '🏸', '🏊', '🥊', '🤸', '🧗', '🩺',
  ]),
  ('Makanan & minuman', [
    '🥗', '🍎', '🍌', '🥦', '🥕', '🍲', '🍚', '🍗',
    '🐟', '🥚', '🥑', '🥪', '🍜', '🥛', '🥤', '🍵',
  ]),
  ('Tidur & relaksasi', [
    '😴', '🌙', '🛏️', '🛌', '😌', '🧖', '🎵', '☕',
  ]),
  ('Belajar & kerja', [
    '📚', '✏️', '💻', '📝', '🎯', '🧠', '⏰', '✅',
    '📈', '🎓', '🔬', '🗓️', '✍️', '🖊️', '📱', '⌨️',
  ]),
  ('Lainnya', [
    '❤️', '😊', '🌱', '✨', '🎮', '🐶', '🎬', '🛒',
  ]),
];

const _categories = ['kesehatan', 'belajar', 'lainnya'];

/// Form tambah/ubah habit — frame 05 mockup.
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  late final TextEditingController _title;
  String _category = 'kesehatan';
  double _weight = 40;
  String? _icon = '🥗';
  bool _active = true;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _loadOnce() {
    if (_init || widget.habitId == null) return;
    _init = true;
    final habits = ref.read(habitListProvider);
    final found = habits.where((h) => h.id == widget.habitId);
    if (found.isEmpty) return;
    final h = found.first;
    _title.text = h.title;
    _category = h.category;
    _weight = h.weight.toDouble();
    _icon = h.icon;
    _active = h.active;
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'Judul minimal 3 huruf.'))),
      );
      return;
    }
    final repo = ref.read(habitListProvider.notifier);
    if (widget.habitId == null) {
      await repo.add(
        title: title,
        category: _category,
        weight: _weight.round(),
        icon: _icon,
      );
    } else {
      final habits = ref.read(habitListProvider);
      final found = habits.where((h) => h.id == widget.habitId);
      if (found.isEmpty) return;
      await repo.update(found.first.copyWith(
        title: title,
        category: _category,
        weight: _weight.round(),
        icon: _icon,
        active: _active,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(ctx, 'Hapus habit?')),
        content: Text(tr(ctx, 'Centang yang sudah tercatat tetap tersimpan.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr(ctx, 'Batal')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr(ctx, 'Hapus')),
          ),
        ],
      ),
    );
    if (ok != true || widget.habitId == null) return;
    await ref.read(habitListProvider.notifier).remove(widget.habitId!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    _loadOnce();
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final line = theme.colorScheme.outline;
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.habitId != null;
    final primaryInk =
        isDark ? AppColors.primary : AppColors.primaryInkLight;
    final primarySoft =
        isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final dangerSoft =
        isDark ? AppColors.dangerSoftDark : AppColors.dangerSoftLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? tr(context, 'Ubah Habit') : tr(context, 'Tambah Habit')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldLabel('Judul habit'),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                hintText: tr(context, 'cth: Minum air 8 gelas'),
              ),
            ),
            const SizedBox(height: 6),
            Text(tr(context, 'Minimal 3 karakter'),
                style: AppText.body(11.5, color: muted)),
            const SizedBox(height: 18),

            _FieldLabel('Ikon habit'),
            const SizedBox(height: 8),
            // Preview ikon terpilih.
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : const Color(0xFF1E1B2E)
                                  .withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(_icon ?? '🥗',
                        style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(context, 'Ikon terpilih'),
                            style: AppText.body(14.4,
                                color: text,
                                weight: FontWeight.w800,
                                height: 1.25)),
                        Text(tr(context, 'Tampil di checklist & daftar habit'),
                            style: AppText.body(11.5,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                                height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Grid 64 emoji per grup.
            for (final (group, emojis) in _emojiGroups) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 7),
                child: Text(
                  tr(context, group).toUpperCase(),
                  style: AppText.body(10.72,
                      color: muted,
                      weight: FontWeight.w800,
                      height: 1.2),
                ),
              ),
              GridView.count(
                crossAxisCount: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 7,
                crossAxisSpacing: 7,
                childAspectRatio: 1,
                children: [
                  for (final e in emojis)
                    GestureDetector(
                      onTap: () => setState(() => _icon = e),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _icon == e
                              ? primarySoft
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: _icon == e
                                ? AppColors.primary
                                : line,
                            width: 1.5,
                          ),
                        ),
                        child: Text(e,
                            style: const TextStyle(fontSize: 19)),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 7),
            Text(
              tr(context,
                  '64 emoji tersedia — ketuk untuk memilih, tampil sebagai ikon habit.'),
              style: AppText.body(11.5, color: muted),
            ),
            const SizedBox(height: 18),

            _FieldLabel('Kategori'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in _categories) ...[
                  _CatChip(
                    label: tr(context, categoryLabel(c)),
                    icon: categoryIcon(c),
                    on: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
                  if (c != _categories.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 18),

            _FieldLabel('Bobot (1–100)'),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: line),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text('${_weight.round()}',
                        style: AppText.display(41.6, color: primaryInk)),
                  ),
                  Expanded(
                    child: Slider(
                      value: _weight,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _weight.round().toString(),
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(context, 'Bobot relatif — total semua habit tidak harus 100. '
                  'Skor = bobot selesai ÷ bobot aktif.'),
              style: AppText.body(11.5, color: muted),
            ),
            const SizedBox(height: 18),

            // Habit aktif.
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: line),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : const Color(0xFF1E1B2E)
                            .withValues(alpha: 0.07),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const IcoChip(icon: 'i-check', tone: IcoTone.green),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(context, 'Habit aktif'),
                            style: AppText.body(14.4,
                                color: text,
                                weight: FontWeight.w800,
                                height: 1.25)),
                        Text(tr(context, 'Muncul di checklist harian & dihitung ke skor'),
                            style: AppText.body(12.16,
                                color: muted, height: 1.3)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              child: Text(tr(context, 'Simpan habit')),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(tr(context, 'Batal')),
            ),
            if (isEdit) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _delete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerSoft,
                  foregroundColor: danger,
                ),
                child: Text(tr(context, 'Hapus habit')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      tr(context, text),
      style: AppText.body(13.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          weight: FontWeight.w800),
    );
  }
}

/// Chip kategori bergaya mockup (pill + ikon SVG).
class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.icon,
    required this.on,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryInk =
        isDark ? AppColors.primary : AppColors.primaryInkLight;
    final primarySoft =
        isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on
              ? primarySoft
              : (isDark
                  ? AppColors.darkSurface2
                  : AppColors.lightSurface2),
          borderRadius: BorderRadius.circular(99),
          border: on ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(icon, size: 14, color: on ? primaryInk : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.body(12.48,
                  color: on ? primaryInk : theme.colorScheme.onSurfaceVariant,
                  weight: FontWeight.w800,
                  height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
