import 'i18n/app_localizations.dart';

/// Format angka gaya Indonesia: koma desimal (72,5 kg); [lang] 'en' → titik.
String fmtKg(double v, {String lang = 'id'}) {
  final s = v.toStringAsFixed(1);
  return lang == 'id' ? s.replaceAll('.', ',') : s;
}

/// Parse input pengguna: terima koma maupun titik.
double? parseKg(String raw) {
  final t = raw.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Selisih berat vs target: "kurang 4,5 kg lagi" / "lebih 1,2 kg" / "tepat!".
/// [lang] 'en' → terjemahkan pola lewat kamus; {x} = angka.
String targetCaption(double latest, double target, {String lang = 'id'}) {
  final diff = latest - target;
  if (diff.abs() < 0.05) return trLang(lang, 'tepat di target! 🎉');
  if (diff > 0) {
    return trLang(lang, 'kurang {x} kg lagi')
        .replaceAll('{x}', fmtKg(diff, lang: lang));
  }
  return trLang(lang, 'lebih {x} kg dari target')
      .replaceAll('{x}', fmtKg(-diff, lang: lang));
}
