import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weight_entry.dart';

/// Baris riwayat timbangan — dipakai kartu Berat (8 terakhir)
/// dan halaman Riwayat lengkap. Ketuk → edit/hapus catatan.
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.entry,
    this.prev,
    this.onTap,
  });

  final WeightEntry entry;
  final WeightEntry? prev;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diff = prev == null ? null : entry.valueKg - prev!.valueKg;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    final lang = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(fmtHistDate(entry.date, lang),
                    style: AppText.body(14.08,
                        color: theme.colorScheme.onSurface,
                        weight: FontWeight.w700)),
              ),
              if (diff != null && diff.abs() >= 0.05)
                Text(
                  diff < 0
                      ? '▼ ${fmtKg(-diff, lang: lang)}'
                      : '▲ ${fmtKg(diff, lang: lang)}',
                  style: AppText.body(12.8,
                      color: diff < 0 ? success : danger,
                      weight: FontWeight.w800),
                ),
              const SizedBox(width: 10),
              Text('${fmtKg(entry.valueKg, lang: lang)} kg',
                  style: AppText.display(16.8,
                      color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tanggal YYYY-MM-DD → "27 Sep 2026" (id) / "27 Sep 2026" (en).
String fmtHistDate(String ymd, String lang) {
  try {
    final d = DateTime.parse(ymd);
    return DateFormat('d MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID')
        .format(d);
  } catch (_) {
    return ymd;
  }
}
