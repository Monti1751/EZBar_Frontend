import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'visual_settings_provider.dart';
import 'localization_provider.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class VisualSettingsPage extends StatelessWidget {
  const VisualSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores dinámicos según switches
    final Color fondo =
        settings.darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFECF0D5);
    final Color texto = settings.darkMode ? Colors.white : Colors.black;

    // Paleta adaptada a daltonismo
    final Color colorPrimario =
        settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color colorSecundario =
        settings.colorBlindMode ? Colors.orange : const Color(0xFFC63425);

    // Tamaño de letra dinámico con 3 opciones
    final double fontSize;
    switch (settings.fontSize) {
      case FontSizeOption.small:
        fontSize = 14;
        break;
      case FontSizeOption.medium:
        fontSize = 18;
        break;
      case FontSizeOption.large:
        fontSize = 22;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimario,
        title: Text(AppLocalizations.of(context).translate('settings_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: fondo,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔥 Switch modo oscuro
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context).translate('dark_mode'),
                style: TextStyle(fontSize: fontSize, color: texto),
              ),
              value: settings.darkMode,
              onChanged: settings.toggleDarkMode,
              activeThumbColor: colorPrimario,
            ),

            // 🔥 Switch daltonismo
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context).translate('color_blind_mode'),
                style: TextStyle(fontSize: fontSize, color: texto),
              ),
              value: settings.colorBlindMode,
              onChanged: settings.toggleColorBlindMode,
              activeThumbColor: colorPrimario,
            ),

            // 🔥 Selector tamaño letra (3 opciones)
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate('font_size'),
                style: TextStyle(fontSize: fontSize, color: texto),
              ),
              subtitle: Text(
                settings.fontSize == FontSizeOption.small
                    ? AppLocalizations.of(context).translate('small')
                    : settings.fontSize == FontSizeOption.medium
                        ? AppLocalizations.of(context).translate('medium')
                        : AppLocalizations.of(context).translate('large'),
                style: TextStyle(color: texto),
              ),
              trailing: DropdownButton<FontSizeOption>(
                value: settings.fontSize,
                dropdownColor: fondo,
                items: [
                  DropdownMenuItem(
                    value: FontSizeOption.small,
                    child:
                        Text(AppLocalizations.of(context).translate('small')),
                  ),
                  DropdownMenuItem(
                    value: FontSizeOption.medium,
                    child:
                        Text(AppLocalizations.of(context).translate('medium')),
                  ),
                  DropdownMenuItem(
                    value: FontSizeOption.large,
                    child:
                        Text(AppLocalizations.of(context).translate('large')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) settings.setFontSize(value);
                },
              ),
            ),

            ListTile(
              title: Text(
                AppLocalizations.of(context).translate('change_language'),
                style: TextStyle(fontSize: fontSize, color: texto),
              ),
              trailing: const Icon(
                Icons.language,
              ),
              onTap: () {
                _showLanguageDialog(context, fontSize, texto, colorPrimario);
              },
            ),

            const Spacer(),

            // 🔥 Botón cerrar sesión
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: colorSecundario),
                label: Text(
                  AppLocalizations.of(context).translate('logout'),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: colorSecundario,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    double fontSize,
    Color texto,
    Color colorPrimario,
  ) {
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);
    final currentLanguage = localizationProvider.currentLocale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).translate('select_language'),
          style: TextStyle(fontSize: fontSize, color: texto),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: localizationProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final langCode = localizationProvider.supportedLanguages[index];
              final langName = localizationProvider.getLanguageName(langCode);
              final isSelected = langCode == currentLanguage;

              return ListTile(
                title: Text(langName),
                trailing:
                    isSelected ? Icon(Icons.check, color: colorPrimario) : null,
                onTap: () async {
                  await localizationProvider.setLocale(Locale(langCode));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
        ],
      ),
    );
  }
}
