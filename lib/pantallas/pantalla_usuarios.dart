import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visual_settings_provider.dart';
import '../config/app_constants.dart';
import '../services/api_service.dart';
import 'settings_menu.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'usuario';
  bool _isActive = true;
  int? _editingUserId;
  bool _isFormExpanded = false;

  List<dynamic> _usuarios = [];
  bool _isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.obtenerUsuarios();
      setState(() {
        _usuarios = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _editingUserId = null;
      _usernameController.clear();
      _passwordController.clear();
      _selectedRole = 'usuario';
      _isActive = true;
      _isFormExpanded = false;
    });
  }

  void _editUser(dynamic user) {
    setState(() {
      _editingUserId = user['id'];
      _usernameController.text = user['username'];
      _passwordController.clear();
      _selectedRole = user['rol'];
      _isActive = user['activo'] == 1 || user['activo'] == true;
      _isFormExpanded = true;
    });
  }

  Future<void> _deleteUser(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Estás seguro de que quieres eliminar este usuario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _apiService.eliminarUsuario(id);
        _cargarUsuarios();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final datos = {
          'username': _usernameController.text,
          'rol': _selectedRole,
          'activo': _isActive,
        };
        
        if (_passwordController.text.isNotEmpty) {
          datos['password'] = _passwordController.text;
        }

        if (_editingUserId != null) {
          await _apiService.actualizarUsuario(_editingUserId!, datos);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario actualizado correctamente')),
          );
        } else {
          if (_passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La contraseña es obligatoria para nuevos usuarios'), backgroundColor: Colors.orange),
            );
            return;
          }
          await _apiService.crearUsuario(datos);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado correctamente')),
          );
        }
        
        _resetForm();
        _cargarUsuarios();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
      errorStyle: const TextStyle(color: Colors.redAccent),
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
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: AppConstants.defaultIconSize),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white, size: AppConstants.defaultIconSize),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Formulario en ExpansionTile
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _editingUserId != null,
                        maintainState: true,
                        key: ValueKey('user_form_$_isFormExpanded'), // Ayuda a forzar el estado si es necesario
                        title: Text(
                          _editingUserId != null ? 'Editar: ${_usernameController.text}' : 'Crear Nuevo Usuario',
                          style: TextStyle(fontWeight: FontWeight.bold, color: barraSuperior),
                        ),
                        leading: Icon(_editingUserId != null ? Icons.edit : Icons.person_add, color: barraSuperior),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: _inputDecoration('Nombre de usuario', Icons.person),
                                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: _inputDecoration(_editingUserId != null ? 'Nueva contraseña (opcional)' : 'Contraseña', Icons.lock),
                                    validator: (value) => (_editingUserId == null && value!.isEmpty) ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedRole,
                                          decoration: _inputDecoration('Rol', Icons.badge),
                                          items: const [
                                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                            DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                                          ],
                                          onChanged: (v) => setState(() => _selectedRole = v!),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        children: [
                                          Text('Activo', style: TextStyle(fontSize: fontSize - 2)),
                                          Switch(
                                            value: _isActive,
                                            onChanged: (v) => setState(() => _isActive = v),
                                            activeColor: barraSuperior,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      if (_editingUserId != null)
                                        Expanded(
                                          child: TextButton(
                                            onPressed: _resetForm,
                                            child: const Text('Cancelar'),
                                          ),
                                        ),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: barraSuperior,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          onPressed: _saveUser,
                                          child: Text(_editingUserId != null ? 'Actualizar' : 'Guardar Usuario', style: const TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
