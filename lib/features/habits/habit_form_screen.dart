import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'habit_repository.dart';
import 'habit_tile.dart';

/// Emoji ikon habit — subset pilihan mockup (penuh 64 ada di desain).
const _emojiChoices = [
  '🥗', '💧', '🚶', '🏃', '🧘', '😴',
  '📚', '💻', '✍️', '🎧', '🧠', '⏰',
  '🍎', '🥦', '🍵', '🚭', '🦷', '🧴',
  '🙏', '📖', '🎨', '🌱', '❤️', '⭐',
];

const _categories = ['kesehatan', 'belajar', 'lainnya'];

/// Form tambah/ubah habit — frame 05 mockup.
/// Edit bila query `id` terisi.
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  late final TextEditingController _title;
  String _category = 'kesehatan';
  double _weight = 20;
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
        const SnackBar(
            content: Text('Judul minimal 3 huruf.')),
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
        title: const Text('Hapus habit?'),
        content:
            const Text('Centang yang sudah tercatat tetap tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
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
    final isEdit = widget.habitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah habit' : 'Habit baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Judul',
                style: AppText.body(13, color: muted,
                    weight: FontWeight.w800)),
            const SizedBox(height: 6),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                hintText: 'cth: Minum air 8 gelas',
              ),
            ),
            const SizedBox(height: 18),
            Text('Kategori',
                style: AppText.body(13, color: muted,
                    weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    label: Text(categoryLabel(c)),
                    selected: _category == c,
                    onSelected: (_) =>
                        setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text('Bobot',
                    style: AppText.body(13, color: muted,
                        weight: FontWeight.w800)),
                const Spacer(),
                Text('${_weight.round()}',
                    style: AppText.display(18, color: text)),
              ],
            ),
            Slider(
              value: _weight,
              min: 1,
              max: 100,
              divisions: 99,
              label: _weight.round().toString(),
              onChanged: (v) => setState(() => _weight = v),
            ),
            Text(
              'Bobot = prioritas. Skor = bobot selesai ÷ bobot aktif.',
              style: AppText.body(11.5, color: muted),
            ),
            const SizedBox(height: 18),
            Text('Ikon habit',
                style: AppText.body(13, color: muted,
                    weight: FontWeight.w800)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
              ),
              itemCount: _emojiChoices.length,
              itemBuilder: (ctx, i) {
                final e = _emojiChoices[i];
                final on = _icon == e;
                return GestureDetector(
                  onTap: () => setState(() => _icon = e),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: on
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: on
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: on ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(e,
                        style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
            if (isEdit) ...[
              const SizedBox(height: 14),
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text('Habit aktif',
                    style: AppText.body(14,
                        color: text,
                        weight: FontWeight.w700)),
                subtitle: Text(
                    'Nonaktif = tak masuk skor & checklist.',
                    style: AppText.body(12, color: muted)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Simpan' : 'Tambah habit'),
            ),
            if (isEdit) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Hapus habit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
