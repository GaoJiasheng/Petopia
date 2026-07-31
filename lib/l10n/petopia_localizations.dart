import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/enums.dart';
import 'english_copy.dart';

/// App-level localization facade.
///
/// Existing Chinese copy is the canonical source during the first localization
/// pass. New copy should use stable keys through [keyed] so additional locales
/// can be added without changing widgets.
class PetopiaLocalizations {
  const PetopiaLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('zh', 'CN'), Locale('en')];

  static const delegate = _PetopiaLocalizationsDelegate();

  static PetopiaLocalizations of(BuildContext context) {
    return Localizations.of<PetopiaLocalizations>(
          context,
          PetopiaLocalizations,
        ) ??
        const PetopiaLocalizations(Locale('zh', 'CN'));
  }

  bool get isEnglish => locale.languageCode == 'en';

  String text(String source) {
    if (!isEnglish || source.isEmpty) return source;
    return EnglishCopy.translate(source);
  }

  String keyed(String key, {required String zhHans, required String en}) {
    assert(key.isNotEmpty);
    return isEnglish ? en : zhHans;
  }

  String bilingual({required String zhHans, required String en}) {
    return isEnglish ? en : zhHans;
  }

  static Locale? localeFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => null,
      AppLanguage.zhHans => const Locale('zh', 'CN'),
      AppLanguage.en => const Locale('en'),
    };
  }

  static Locale resolveDeviceLocale(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale?.languageCode == 'zh') return const Locale('zh', 'CN');
    return const Locale('en');
  }
}

extension PetopiaLocalizationContext on BuildContext {
  PetopiaLocalizations get l10n => PetopiaLocalizations.of(this);

  String tr(String source) => l10n.text(source);
}

class _PetopiaLocalizationsDelegate
    extends LocalizationsDelegate<PetopiaLocalizations> {
  const _PetopiaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'zh' || locale.languageCode == 'en';

  @override
  Future<PetopiaLocalizations> load(Locale locale) =>
      SynchronousFuture(PetopiaLocalizations(locale));

  @override
  bool shouldReload(_PetopiaLocalizationsDelegate old) => false;
}
