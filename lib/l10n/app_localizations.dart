import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class AppLocalizations {
  final Locale locale;
  late LocalizationService _localizationService;

  AppLocalizations(this.locale) {
    _localizationService = LocalizationService();
    // Asegurar que el servicio tiene el locale correcto
    _localizationService.setLocale(locale);
  }

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (instance == null) {
      // Si no hay instancia, crear una nueva con el locale por defecto
      return AppLocalizations(const Locale('es'));
    }
    return instance;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String translate(String key) {
    return _localizationService.translate(key);
  }

  String translateWithFallback(String key, String fallback) {
    return _localizationService.translateWithFallback(key, fallback);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en', 'fr', 'ca', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
