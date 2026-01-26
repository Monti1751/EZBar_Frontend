import 'package:flutter/material.dart';
import '../providers/visual_settings_provider.dart';
import '../l10n/app_localizations.dart';

class AddZoneButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final VisualSettingsProvider settings;

  const AddZoneButton({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;
    final double fontSize = settings.currentFontSize;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black54),
        ),
        child: Text(
          AppLocalizations.of(context).translate('add_zone'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textoGeneral,
          ),
        ),
      ),
    );
  }
}