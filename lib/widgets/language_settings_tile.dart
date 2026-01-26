import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../l10n/app_localizations.dart';

/// Widget para mostrar un selector de idioma en los ajustes
///
/// Ejemplo de uso en settings_menu.dart:
///
/// ```dart
/// import 'widgets/language_settings_tile.dart';
///
/// LanguageSettingsTile(
///   onLanguageChanged: () {
///     // Actualizar UI si es necesario
///   },
/// )
/// ```

class LanguageSettingsTile extends StatelessWidget {
  final VoidCallback? onLanguageChanged;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;

  const LanguageSettingsTile({
    super.key,
    this.onLanguageChanged,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final localizations = AppLocalizations.of(context);
        final currentLanguage = localizationProvider.currentLocale.languageCode;
        final displayFontSize = fontSize ?? 16.0;
        final displayTextColor = textColor ?? Colors.black;

        return Container(
          color: backgroundColor,
          child: ListTile(
            title: Text(
              localizations.translate('select_language'),
              style: TextStyle(
                fontSize: displayFontSize,
                color: displayTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: DropdownButton<String>(
              value: currentLanguage,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  localizationProvider.setLocale(Locale(newLanguage));
                  onLanguageChanged?.call();

                  // Mostrar notificación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.translate('language_changed'),
                        style: TextStyle(fontSize: displayFontSize),
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              items: localizationProvider.supportedLanguages
                  .map<DropdownMenuItem<String>>((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(
                        localizationProvider.getLanguageName(language),
                        style: TextStyle(fontSize: displayFontSize - 2),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar el selector de idioma como ListTile con icono
class LanguageSettingsOption extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;
  final Color? tileColor;

  const LanguageSettingsOption({
    super.key,
    this.fontSize,
    this.textColor,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final localizations = AppLocalizations.of(context);
        final currentLanguage = localizationProvider.currentLocale.languageCode;
        final displayFontSize = fontSize ?? 16.0;
        final displayTextColor = textColor ?? Colors.black;

        return Container(
          color: tileColor,
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              localizations.translate('select_language'),
              style: TextStyle(
                fontSize: displayFontSize,
                color: displayTextColor,
              ),
            ),
            subtitle: Text(
              localizationProvider.getLanguageName(currentLanguage),
              style: TextStyle(
                fontSize: displayFontSize - 2,
                color: displayTextColor.withValues(alpha: 0.7),
              ),
            ),
            onTap: () => _showLanguageDialog(
              context,
              localizationProvider,
              localizations,
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocalizationProvider localizationProvider,
    AppLocalizations localizations,
  ) {
    final currentLanguage = localizationProvider.currentLocale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localizationProvider.supportedLanguages.map<Widget>((
              String language,
            ) {
              final isSelected = currentLanguage == language;
              return ListTile(
                leading: isSelected
                    ? const Icon(
                        Icons.radio_button_checked,
                        color: Colors.green,
                      )
                    : const Icon(Icons.radio_button_unchecked),
                title: Text(localizationProvider.getLanguageName(language)),
                onTap: () {
                  localizationProvider.setLocale(Locale(language));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.translate('cancel')),
            ),
          ],
        );
      },
    );
  }
}
