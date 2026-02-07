import 'package:flutter/material.dart';
import '../providers/visual_settings_provider.dart';

class TopBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color backgroundColor;
  final VisualSettingsProvider settings;

  const TopBar({
    super.key,
    required this.scaffoldKey,
    required this.backgroundColor,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    return Container(
      height: kToolbarHeight, // Estándar de flutter
      color: backgroundColor,
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: textoGeneral, size: 28),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }
}