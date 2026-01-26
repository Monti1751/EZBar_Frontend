import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();
  
  Locale _currentLocale = const Locale('es');
  
  LocalizationProvider() {
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;
  
  LocalizationService get localizationService => _localizationService;

  List<String> get supportedLanguages => _localizationService.supportedLanguages;

  String getLanguageName(String languageCode) => 
    _localizationService.languageNames[languageCode] ?? languageCode;

  Future<void> setLocale(Locale locale) async {
    if (!_localizationService.supportedLanguages.contains(locale.languageCode)) {
      return;
    }

    _currentLocale = locale;
    _localizationService.setLocale(locale);
    
    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    
    notifyListeners();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code') ?? 'es';
    
    if (_localizationService.supportedLanguages.contains(savedLanguage)) {
      _currentLocale = Locale(savedLanguage);
      _localizationService.setLocale(_currentLocale);
    }
  }

  String translate(String key) {
    return _localizationService.translate(key);
  }
}
