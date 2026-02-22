import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/ajustes_visuales.dart';
import '../providers/visual_settings_provider.dart';
import '../providers/auth_provider.dart';
import 'pantalla_principal.dart';
import 'carta_page.dart';
import 'pantalla_usuarios.dart';
import '../l10n/app_localizations.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Colores dinámicos según ajustes
    final Color fondo = settings.darkMode ? Colors.black : Colors.white;
    final Color encabezado =
        settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    // Tamaños dinámicos
    final double fontSize = settings.currentFontSize;

    final double headerFontSize = settings.fontSize == FontSizeOption.small
        ? 18
        : settings.fontSize == FontSizeOption.medium
            ? 22
            : 26;

    final double logoutFontSize = settings.fontSize == FontSizeOption.small
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
                AppLocalizations.of(context).translate('settings_header'),
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
                    if (auth.isAdmin) ...[
                      _menuItem(
                        icon: Icons.person_pin,
                        text: AppLocalizations.of(context)
                            .translate('manage_roles'),
                        onTap: () {},
                        textoColor: textoGeneral,
                        fontSize: fontSize,
                      ),
                      _menuItem(
                        icon: Icons.menu_book,
                        text:
                            AppLocalizations.of(context).translate('edit_menu'),
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
                        text: AppLocalizations.of(context)
                            .translate('edit_users'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PantallaUsuarios(),
                            ),
                          );
                        },
                        textoColor: textoGeneral,
                        fontSize: fontSize,
                      ),
                      _menuItem(
                        icon: Icons.inventory,
                        text: AppLocalizations.of(context)
                            .translate('edit_inventory'),
                        onTap: () {},
                        textoColor: textoGeneral,
                        fontSize: fontSize,
                      ),
                    ],
                    _menuItem(
                      icon: Icons.brush,
                      text: AppLocalizations.of(context)
                          .translate('settings_header'),
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
                      text: AppLocalizations.of(context)
                          .translate('main_menu_access'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaPrincipal(),
                          ),
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
                    // Limpiar la variable de sesión al salir
                    Provider.of<AuthProvider>(context, listen: false).logout();

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
                    color: settings.colorBlindMode
                        ? Colors.orange
                        : const Color(0xFFC63425),
                  ),
                  label: Text(
                    AppLocalizations.of(context).translate('logout'),
                    style: TextStyle(
                      fontSize: logoutFontSize,
                      fontWeight: FontWeight.bold,
                      color: settings.colorBlindMode
                          ? Colors.orange
                          : const Color(0xFFC63425),
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
      title: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: textoColor),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textoColor),
    );
  }
}
