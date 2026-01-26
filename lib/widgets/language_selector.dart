import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final bool isExpanded;
  
  const LanguageSelector({
    super.key,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final currentLanguage = localizationProvider.currentLocale.languageCode;
        final localizations = AppLocalizations.of(context);

        return PopupMenuButton<String>(
          onSelected: (String languageCode) {
            localizationProvider.setLocale(Locale(languageCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('language_changed')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          itemBuilder: (BuildContext context) {
            return localizationProvider.supportedLanguages
                .map<PopupMenuEntry<String>>((String language) {
              return PopupMenuItem<String>(
                value: language,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizationProvider.getLanguageName(language)),
                    if (currentLanguage == language) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 18),
                    ],
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 8),
                Text(
                  localizationProvider.getLanguageName(currentLanguage),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final currentLanguage = localizationProvider.currentLocale.languageCode;
        final localizations = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(localizations.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localizationProvider.supportedLanguages
                .map<Widget>((String language) {
              final isSelected = currentLanguage == language;
              return ListTile(
                leading: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle_outlined),
                title: Text(localizationProvider.getLanguageName(language)),
                onTap: () {
                  localizationProvider.setLocale(Locale(language));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('language_changed')),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
