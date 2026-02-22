import 'package:flutter/material.dart';
import '../providers/visual_settings_provider.dart';
import '../l10n/app_localizations.dart';

class AddZoneField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final Color buttonColor;
  final VisualSettingsProvider settings;

  const AddZoneField({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.buttonColor,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context).translate('zone_name_hint'),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: settings.darkMode ? Colors.grey[800] : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: settings.darkMode
                      ? Colors.white70
                      : const Color(0xFF4A4025),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: settings.darkMode
                      ? Colors.greenAccent
                      : const Color(0xFF7BA238),
                  width: 2.2,
                ),
              ),
            ),
            style: TextStyle(color: textoGeneral),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.check, color: buttonColor),
          onPressed: () => onSubmit(controller.text),
        ),
      ],
    );
  }
}
