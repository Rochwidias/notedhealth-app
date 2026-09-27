import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';
import '../../models/weight_entry.dart';
import '../habits/daily_log_store.dart';

/// Riwayat timbangan dari box Hive `weights`.
/// Kunci = tanggal YYYY-MM-DD → 1 tanggal = 1 catatan (input ulang = update).
final weightHistoryProvider =
    NotifierProvider<WeightController, List<WeightEntry>>(
        WeightController.new);

/// Timbangan terakhir (paling baru), null bila belum pernah catat.
final latestWeightProvider = Provider<WeightEntry?>((ref) {
  final history = ref.watch(weightHistoryProvider);
  return history.isEmpty ? null : history.first;
});

class WeightController extends Notifier<List<WeightEntry>> {
  Box get _box => Hive.box('weights');

  @override
  List<WeightEntry> build() => _all();

  List<WeightEntry> _all() {
    final items = <WeightEntry>[];
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is Map) items.add(WeightEntry.fromMap(key.toString(), v));
    }
    // Terbaru dulu (tanggal desc).
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Simpan timbangan. Validasi 20–300 kg, lempar [FormatException]
  /// dengan pesan aman tampil bila di luar rentang.
  Future<void> save(double kg, {DateTime? date}) async {
    if (kg < 20 || kg > 300) {
      throw const FormatException('Berat harus 20–300 kg.');
    }
    final key = dateKey(date ?? DateTime.now());
    detachHive(_box.put(key, {'valueKg': kg, 'date': key}), 'weights/save');
    state = _all();
  }

  Future<void> remove(String date) async {
    detachHive(_box.delete(date), 'weights/remove');
    state = _all();
  }
}
