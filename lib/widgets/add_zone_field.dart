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
              hintText: AppLocalizations.of(context).translate('zone_name_hint'),
              border: const OutlineInputBorder(),
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