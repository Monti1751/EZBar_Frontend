import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'ajustes_visuales.dart';
import 'visual_settings_provider.dart';
import 'pantalla_principal.dart';
import 'CartaPage.dart';
import 'Usuario.dart';
import 'cuenta.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores dinámicos según ajustes
    final Color fondo = settings.darkMode ? Colors.black : Colors.white;
    final Color encabezado = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    // Tamaños dinámicos
    final double fontSize = settings.currentFontSize;

    final double headerFontSize =
        settings.fontSize == FontSizeOption.small
            ? 18
            : settings.fontSize == FontSizeOption.medium
                ? 22
                : 26;

    final double logoutFontSize =
        settings.fontSize == FontSizeOption.small
            ? 14
            : settings.fontSize == FontSizeOption.medium
                ? 16
                : 18;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado del menú
            Container(
              padding: const EdgeInsets.all(20),
              color: encabezado,
              child: Text(
                "Ajustes",
                style: TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: textoGeneral,
                ),
              ),
            ),

            // Lista de opciones
            Expanded(
              child: Container(
                color: fondo,
                child: ListView(
                  children: [
                    _menuItem(
                      icon: Icons.person_pin,
                      text: "Administrar roles",
                      onTap: () {},
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),
                    _menuItem(
                      icon: Icons.menu_book,
                      text: "Editar carta",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartaPage(),
                          ),
                        );
                      },
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),
                    _menuItem(
                      icon: Icons.group,
                      text: "Editar usuarios",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditarCrearUsuarioPage(),
                          ),
                        );
                      },
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),

                    _menuItem(
                      icon: Icons.inventory,
                      text: "Editar inventario",
                      onTap: () {},
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),
                    _menuItem(
                      icon: Icons.brush,
                      text: "Ajustes visuales",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VisualSettingsPage(),
                          ),
                        );
                      },
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),
                    _menuItem(
                      icon: Icons.approval,
                      text: "Acceso Menú Principal",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PantallaPrincipal()),
                        );
                      },
                      textoColor: textoGeneral,
                      fontSize: fontSize,
                    ),
                  ],
                ),
              ),
            ),

            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
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
                  icon: Icon(
                    Icons.logout,
                    color: settings.colorBlindMode ? Colors.orange : const Color(0xFFC63425),
                  ),
                  label: Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      fontSize: logoutFontSize,
                      fontWeight: FontWeight.bold,
                      color: settings.colorBlindMode ? Colors.orange : const Color(0xFFC63425),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constructor de ítems del menú
  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color textoColor,
    required double fontSize,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26, color: textoColor),
      title: Text(text, style: TextStyle(fontSize: fontSize, color: textoColor)),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textoColor),
    );
  }
}