import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weight_entry.dart';
import '../../widgets/svg_icon.dart';
import '../profile/prefs_store.dart';
import '../widget/weight_widget_service.dart';
import 'weight_repository.dart';

/// Bottom sheet catat timbangan — frame 06 mockup.
/// Bisa dipanggil dari Beranda (FAB), layar Berat, maupun baris riwayat
/// (isi [entry] = mode ubah/hapus catatan lama).
Future<void> showWeightSheet(BuildContext context, {WeightEntry? entry}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => WeightSheet(entry: entry),
  );
}

class WeightSheet extends ConsumerStatefulWidget {
  const WeightSheet({super.key, this.entry});

  /// Catatan yang diedit; null = mode catat baru (tanggal hari ini).
  final WeightEntry? entry;

  @override
  ConsumerState<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<WeightSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.entry;
    if (existing != null) {
      _ctrl = TextEditingController(text: fmtKg(existing.valueKg));
    } else {
      final latest = ref.read(latestWeightProvider);
      _ctrl = TextEditingController(
        text: latest == null ? '' : fmtKg(latest.valueKg),
      );
    }
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
        SnackBar(
            content: Text(tr(context, 'Isi berat dulu, contoh: 72,5'))),
      );
      return;
    }
    try {
      final date =
          widget.entry == null ? null : DateTime.tryParse(widget.entry!.date);
      await ref.read(weightHistoryProvider.notifier).save(kg, date: date);
      unawaited(refreshWeightWidget());
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(ctx, 'Hapus catatan berat ini?')),
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
    if (ok != true || !mounted) return;
    await ref
        .read(weightHistoryProvider.notifier)
        .remove(widget.entry!.date);
    unawaited(refreshWeightWidget());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefs = ref.watch(prefsProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final previewKg = parseKg(_ctrl.text);
    final bmi = prefs.bmi(
        previewKg ?? ref.watch(latestWeightProvider)?.valueKg);
    final primarySoft = isDark
        ? AppColors.primarySoftDark
        : AppColors.primarySoftLight;
    final primaryInk = isDark
        ? AppColors.primaryInkDark
        : AppColors.primaryInkLight;
    final successSoft =
        isDark ? AppColors.successSoftDark : AppColors.successSoftLight;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final today = DateFormat('EEEE, d MMM yyyy',
            lang == 'en' ? 'en_US' : 'id_ID')
        .format(DateTime.now());
    final editing = widget.entry != null;
    final entryDate = widget.entry == null
        ? null
        : DateTime.tryParse(widget.entry!.date);
    final chipDate = entryDate == null
        ? today
        : DateFormat('EEEE, d MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID')
            .format(entryDate);

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface3
                  : AppColors.lightSurface3,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Text(
              editing
                  ? tr(context, 'Ubah catatan')
                  : tr(context, 'Catat berat'),
              style: AppText.display(20,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(
            editing
                ? tr(context, 'Perbarui berat untuk tanggal ini.')
                : tr(context,
                    'Sekali per tanggal — input ulang tanggal sama = update.'),
            textAlign: TextAlign.center,
            style: AppText.body(11.5,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          // Chip tanggal hari ini.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primarySoft,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgIcon('i-calendar', size: 15, color: primaryInk),
                const SizedBox(width: 7),
                Text(chipDate,
                    style: AppText.body(12.48,
                        color: primaryInk,
                        weight: FontWeight.w800,
                        height: 1.2)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 170,
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppText.display(57.6,
                      weight: FontWeight.w600,
                      color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: tr(context, '0,0'),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 6),
                child: Text(tr(context, 'kg'),
                    style: AppText.body(17.6,
                        color: theme.colorScheme.onSurfaceVariant,
                        weight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (bmi != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: successSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'BMI ${lang == 'id'
                        ? bmi.toStringAsFixed(1).replaceAll('.', ',')
                        : bmi.toStringAsFixed(1)}'
                    ' · ${tr(context, bmiCategory(bmi))}',
                    style: AppText.body(12.48,
                        color: success, weight: FontWeight.w800),
                  ),
                ),
                if (prefs.heightCm != null) ...[
                  const SizedBox(width: 8),
                  Text(
                      tr(context, 'dari tinggi {x} cm')
                          .replaceAll('{x}', '${prefs.heightCm}'),
                      style: AppText.body(11.5,
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            )
          else
            Text(tr(context, 'Isi tinggi di Profil untuk lihat BMI.'),
                style: AppText.body(12,
                    color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Text(
            tr(
              context,
              'Rentang valid 20–300 kg · tanggal tidak boleh '
              'jauh ke masa depan',
            ),
            textAlign: TextAlign.center,
            style: AppText.body(11,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (editing) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.dangerDark
                          : AppColors.dangerLight,
                      side: BorderSide(
                          color: isDark
                              ? AppColors.dangerDark
                              : AppColors.dangerLight),
                    ),
                    child: Text(tr(context, 'Hapus')),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr(context, 'Batal')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(tr(context, 'Simpan')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
