import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import 'history_row.dart';
import 'weight_repository.dart';
import 'weight_sheet.dart';

/// Halaman "Semua" — seluruh riwayat timbangan (tanpa batas 8 baris).
/// Ketuk baris → sheet ubah/hapus catatan.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final history = ref.watch(weightHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Riwayat')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  tr(context, 'Belum ada catatan'),
                  textAlign: TextAlign.center,
                  style: AppText.body(14.08, color: muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: history.length + 1,
              separatorBuilder: (_, _) =>
                  Divider(color: theme.colorScheme.outline, height: 1),
              itemBuilder: (ctx, i) {
                if (i == history.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      tr(context, 'Ketuk baris untuk ubah atau hapus.'),
                      textAlign: TextAlign.center,
                      style: AppText.body(12, color: muted),
                    ),
                  );
                }
                return HistoryRow(
                  entry: history[i],
                  prev: i + 1 < history.length ? history[i + 1] : null,
                  onTap: () => showWeightSheet(context, entry: history[i]),
                );
              },
            ),
    );
  }
}
