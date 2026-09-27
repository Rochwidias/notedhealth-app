/// Format angka gaya Indonesia: koma desimal (72,5 kg).
String fmtKg(double v) =>
    v.toStringAsFixed(1).replaceAll('.', ',');

/// Parse input pengguna: terima koma maupun titik.
double? parseKg(String raw) {
  final t = raw.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Selisih berat vs target: "kurang 4,5 kg lagi" / "lebih 1,2 kg" / "tepat!".
String targetCaption(double latest, double target) {
  final diff = latest - target;
  if (diff.abs() < 0.05) return 'tepat di target! 🎉';
  if (diff > 0) return 'kurang ${fmtKg(diff)} kg lagi';
  return 'lebih ${fmtKg(-diff)} kg dari target';
}
