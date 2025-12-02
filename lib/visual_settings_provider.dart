import 'package:flutter/material.dart';

class VisualSettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _colorBlindMode = false;
  bool _smallFont = false;

  bool get darkMode => _darkMode;
  bool get colorBlindMode => _colorBlindMode;
  bool get smallFont => _smallFont;

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void toggleColorBlindMode(bool value) {
    _colorBlindMode = value;
    notifyListeners();
  }

  void toggleSmallFont(bool value) {
    _smallFont = value;
    notifyListeners();
  }
}
