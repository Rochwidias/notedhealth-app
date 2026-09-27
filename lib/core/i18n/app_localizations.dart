import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'strings.dart';

/// Localizations sederhana ID/EN.
///
/// Sumber teks tetap bahasa Indonesia di kode; [tr] menerjemahkan ke EN
/// lewat kamus [kEn] bila bahasa aktif `en` (fallback: teks asli).
class AppLocalizations {
  const AppLocalizations(this.languageCode);

  final String languageCode;

  bool get isEn => languageCode == 'en';

  /// Terjemahkan [source] sesuai bahasa aktif.
  String call(String source) => trLang(languageCode, source);

  static const supportedLocales = [Locale('id'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations('id');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'id' || locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale.languageCode));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Terjemahan tanpa BuildContext (untuk helper/model).
String trLang(String languageCode, String source) {
  if (languageCode != 'en') return source;
  final key = source.trim().split(RegExp(r'\s+')).join(' ');
  return kEn[key] ?? source;
}

/// Terjemah teks Indonesia → bahasa aktif dari [context].
String tr(BuildContext context, String source) {
  final lang = Localizations.localeOf(context).languageCode;
  return trLang(lang, source);
}
