import 'package:flutter/material.dart';
import 'main.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado del menú
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF7BA238),
              child: const Text(
                "Ajustes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Lista de opciones
            Expanded(
              child: ListView(
                children: [
                  _menuItem(
                    icon: Icons.person_pin,
                    text: "Administrar roles",
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.menu_book,
                    text: "Editar carta",
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.group,
                    text: "Editar usuarios",
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.food_bank_outlined,
                    text: "Editar platos",
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.inventory,
                    text: "Editar inventario",
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.brush,
                    text: "Ajustes visuales",
                    onTap: () {},
                  ),
                ],
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
                  icon: const Icon(Icons.logout, color: Color(0xFFC63425)),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC63425),
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
  }) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(text, style: const TextStyle(fontSize: 17)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}