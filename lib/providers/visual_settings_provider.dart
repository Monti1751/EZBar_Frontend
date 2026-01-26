import 'package:flutter/material.dart';

enum FontSizeOption { small, medium, large }

class VisualSettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _colorBlindMode = false;
  FontSizeOption _fontSize = FontSizeOption.medium; // valor por defecto

  bool get darkMode => _darkMode;
  bool get colorBlindMode => _colorBlindMode;
  FontSizeOption get fontSize => _fontSize;

  // 🔥 Getter directo para usar en los widgets
  double get currentFontSize {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 14;
      case FontSizeOption.medium:
        return 18;
      case FontSizeOption.large:
        return 22;
    }
  }

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void toggleColorBlindMode(bool value) {
    _colorBlindMode = value;
    notifyListeners();
  }

  void setFontSize(FontSizeOption option) {
    _fontSize = option;
    notifyListeners();
  }
}
