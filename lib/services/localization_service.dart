import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  
  late Map<String, Map<String, String>> _localizedValues;
  Locale _currentLocale = const Locale('es');
  
  final List<String> supportedLanguages = ['es', 'en', 'fr', 'ca', 'zh'];
  final Map<String, String> languageNames = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
    'ca': 'Català',
    'zh': '中文',
  };

  LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  Future<void> init() async {
    _localizedValues = {};
    
    for (String lang in supportedLanguages) {
      final String jsonString = await rootBundle.loadString('lib/l10n/$lang.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _localizedValues[lang] = jsonMap.cast<String, String>();
    }
  }

  void setLocale(Locale locale) {
    if (supportedLanguages.contains(locale.languageCode)) {
      _currentLocale = locale;
    }
  }

  Locale get currentLocale => _currentLocale;

  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }

  String translateWithFallback(String key, String fallback) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? fallback;
  }

  List<Locale> get supportedLocales => supportedLanguages
      .map((String languageCode) => Locale(languageCode))
      .toList();
}
