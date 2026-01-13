import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:log_in/settings_menu.dart';
import 'package:provider/provider.dart';
import 'visual_settings_provider.dart';


class Usuario {
  String username;
  String nombre;
  String password;
  String rol;
  File? imagen;

  Usuario({
    required this.username,
    required this.nombre,
    required this.password,
    required this.rol,
    this.imagen,
  });
}

class EditarCrearUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const EditarCrearUsuarioPage({super.key, this.usuario});

  @override
  State<EditarCrearUsuarioPage> createState() => _EditarCrearUsuarioPageState();
}

class _EditarCrearUsuarioPageState extends State<EditarCrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _imagen;

  late TextEditingController _usernameController;
  late TextEditingController _nombreController;
  late TextEditingController _passwordController;

  String _rolSeleccionado = "Camarero";

  final List<String> roles = [
    "Camarero",
    "Cocina",
    "Administrador",
  ];

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: widget.usuario?.username ?? "");
    _nombreController = TextEditingController(text: widget.usuario?.nombre ?? "");
    _passwordController = TextEditingController(text: widget.usuario?.password ?? "");
    _rolSeleccionado = widget.usuario?.rol ?? "Camarero";
    _imagen = widget.usuario?.imagen;
  }

  Future<void> _seleccionarImagen() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Seleccionar imagen"),
        content: const Text("¿Quieres tomar una foto o elegir de la galería?"),
        actions: [
          TextButton(
            onPressed: () async {
              final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
              if (foto != null) setState(() => _imagen = File(foto.path));
              Navigator.pop(ctx);
            },
            child: const Text("Cámara"),
          ),
          TextButton(
            onPressed: () async {
              final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
              if (img != null) setState(() => _imagen = File(img.path));
              Navigator.pop(ctx);
            },
            child: const Text("Galería"),
          ),
        ],
      ),
    );
  }

  InputDecoration loginInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF4A4025)),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF4A4025),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF7BA238),
          width: 2.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    final bool esEdicion = widget.usuario != null;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: barraSuperior,
        title: Text(
          esEdicion ? "Editar usuario" : "Crear usuario",
          style: TextStyle(color: textoGeneral),
        ),
        iconTheme: IconThemeData(color: textoGeneral),
      ),
      drawer: const SettingsMenu(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imagen != null ? FileImage(_imagen!) : null,
                  child: _imagen == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.black45)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _usernameController,
                decoration: loginInputDecoration("Nombre de usuario", Icons.person),
                validator: (v) => v!.isEmpty ? "Introduce un nombre de usuario" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nombreController,
                decoration: loginInputDecoration("Nombre", Icons.badge),
                validator: (v) => v!.isEmpty ? "Introduce un nombre" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: loginInputDecoration("Contraseña", Icons.lock),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Introduce una contraseña" : null,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4A4025), width: 1.5),
                ),
                child: DropdownButtonFormField<String>(
                  value: _rolSeleccionado,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: roles.map((rol) {
                    return DropdownMenuItem(
                      value: rol,
                      child: Text(rol),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _rolSeleccionado = v!),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: barraSuperior,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  esEdicion ? "Guardar cambios" : "Crear usuario",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              if (esEdicion) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Eliminar usuario"),
                        content: const Text("¿Seguro que quieres eliminar este usuario?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Eliminar usuario", style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}