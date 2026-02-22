import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visual_settings_provider.dart';
import '../config/app_constants.dart';
import 'settings_menu.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'usuario';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      // TODO: Connect to backend API to save user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Guardando usuario...'),
          backgroundColor:
              Provider.of<VisualSettingsProvider>(context, listen: false)
                      .colorBlindMode
                  ? Colors.blue
                  : AppConstants.primaryGreen,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool darkMode) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppConstants.darkBrown),
      filled: true,
      fillColor: darkMode ? Colors.grey[800] : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(
            color: AppConstants.darkBrown, width: AppConstants.borderWidthThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(
            color: AppConstants.primaryGreen,
            width: AppConstants.borderWidthThick),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores estándar de la app
    final Color fondo = settings.darkMode
        ? const Color(0xFF1E1E1E)
        : AppConstants.backgroundCream;
    final Color barraSuperior =
        settings.colorBlindMode ? Colors.blue : AppConstants.primaryGreen;
    final Color textoGeneral =
        settings.darkMode ? Colors.white : AppConstants.darkBrown;

    final double fontSize = settings.currentFontSize;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          // Barra superior
          Container(
            height: AppConstants.appBarHeight,
            color: barraSuperior,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: textoGeneral, size: AppConstants.defaultIconSize),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: Icon(Icons.menu,
                      color: textoGeneral, size: AppConstants.defaultIconSize),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Datos del usuario:',
                      style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: textoGeneral),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: textoGeneral, fontSize: fontSize),
                      decoration: _inputDecoration(
                          'Nombre de usuario', Icons.person, settings.darkMode),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un nombre de usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textoGeneral, fontSize: fontSize),
                      decoration: _inputDecoration(
                          'Contraseña', Icons.lock, settings.darkMode),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: _inputDecoration(
                          'Rol', Icons.badge, settings.darkMode),
                      style: TextStyle(color: textoGeneral, fontSize: fontSize),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                            value: 'admin', child: Text('Administrador')),
                        DropdownMenuItem(
                            value: 'usuario', child: Text('Usuario')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingXXLarge),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: barraSuperior,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.buttonPaddingVertical),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                          )),
                      onPressed: _saveUser,
                      child: Text('Guardar',
                          style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
