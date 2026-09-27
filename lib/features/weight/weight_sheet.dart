import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../profile/prefs_store.dart';
import 'weight_repository.dart';

/// Bottom sheet catat timbangan — frame 06 mockup.
/// Bisa dipanggil dari Beranda (FAB) maupun layar Berat.
Future<void> showWeightSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const WeightSheet(),
  );
}

class WeightSheet extends ConsumerStatefulWidget {
  const WeightSheet({super.key});

  @override
  ConsumerState<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<WeightSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final latest = ref.read(latestWeightProvider);
    _ctrl = TextEditingController(
      text: latest == null ? '' : fmtKg(latest.valueKg),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kg = parseKg(_ctrl.text);
    if (kg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi berat dulu, contoh: 72,5')),
      );
      return;
    }
    try {
      await ref.read(weightHistoryProvider.notifier).save(kg);
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(prefsProvider);
    final previewKg = parseKg(_ctrl.text);
    final bmi = prefs.bmi(
        previewKg ?? ref.watch(latestWeightProvider)?.valueKg);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Text('Catat berat hari ini',
              style: AppText.display(19,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppText.display(44,
                      color: theme.colorScheme.onSurface),
                  decoration: const InputDecoration(hintText: '0,0'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 6),
                child: Text('kg',
                    style: AppText.body(16,
                        color: theme.colorScheme.onSurfaceVariant,
                        weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (bmi != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'BMI ${bmi.toStringAsFixed(1).replaceAll('.', ',')} · ${bmiCategory(bmi)}',
                style: AppText.body(12.5,
                    color: theme.colorScheme.onPrimaryContainer,
                    weight: FontWeight.w800),
              ),
            )
          else
            Text('Isi tinggi di Profil untuk lihat BMI.',
                style: AppText.body(12,
                    color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
