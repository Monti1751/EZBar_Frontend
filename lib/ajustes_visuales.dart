import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'visual_settings_provider.dart';
import 'main.dart';

class VisualSettingsPage extends StatelessWidget {
  const VisualSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores dinámicos según switches
    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color texto = settings.darkMode ? Colors.white : Colors.black;

    // Paleta adaptada a daltonismo
    final Color colorPrimario = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color colorSecundario = settings.colorBlindMode ? Colors.orange : const Color(0xFFC63425);

    // Tamaño de letra dinámico
    final double fontSize = settings.smallFont ? 14 : 18;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimario,
        title: const Text("Ajustes visuales"),
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
              title: Text("Modo oscuro", style: TextStyle(fontSize: fontSize, color: texto)),
              value: settings.darkMode,
              onChanged: settings.toggleDarkMode,
              activeColor: colorPrimario,
            ),

            // 🔥 Switch daltonismo
            SwitchListTile(
              title: Text("Modo daltonismo", style: TextStyle(fontSize: fontSize, color: texto)),
              value: settings.colorBlindMode,
              onChanged: settings.toggleColorBlindMode,
              activeColor: colorPrimario,
            ),

            // 🔥 Switch tamaño letra
            SwitchListTile(
              title: Text("Tamaño letra", style: TextStyle(fontSize: fontSize, color: texto)),
              subtitle: Text(
                settings.smallFont ? "Letra pequeña" : "Letra grande",
                style: TextStyle(color: texto),
              ),
              value: settings.smallFont,
              onChanged: settings.toggleSmallFont,
              activeColor: colorPrimario,
            ),

            const Spacer(),

            // 🔥 Botón cerrar sesión
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: colorSecundario),
                label: Text(
                  "Cerrar sesión",
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
}
