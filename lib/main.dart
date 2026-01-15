import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'visual_settings_provider.dart';
import 'pantalla_principal.dart';
import 'services/api_service.dart';
import 'config/api_config.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VisualSettingsProvider(),
      child: const EzBarApp(),
    ),
  );
}

class EzBarApp extends StatelessWidget {
  const EzBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    return MaterialApp(
      title: 'EZBar',
      debugShowCheckedModeBanner: false,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFECF0D5),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFECF0D5),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
        ),
      ),
      home: const ConnectionWrapper(),
    );
  }
}

class ConnectionWrapper extends StatefulWidget {
  const ConnectionWrapper({super.key});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  bool _searching = true;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _searching = true;
    });

    // Intentar conectar con la IP guardada o descubrir nueva
    bool success = await ApiConfig.findServer();

    if (mounted) {
      setState(() {
        _found = success;
        _searching = false;
      });
    }
  }

  Future<void> _showManualConfigDialog() {
    TextEditingController ipController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar IP Manual'),
        content: TextField(
          controller: ipController,
          decoration: const InputDecoration(
            hintText: 'Ej: 192.168.1.35',
            labelText: 'Dirección IP',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el dialogo
              if (ipController.text.isNotEmpty) {
                ApiConfig.setManualIp(ipController.text);
                setState(() {
                  _searching = true;
                });

                // Verificar conexión con la nueva IP
                bool connected = await ApiService().verificarConexion();

                if (mounted) {
                  setState(() {
                    _searching = false;
                    _found = connected;
                  });

                  if (!connected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo conectar. Verifica la IP y el Firewall.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mientras busca, mostrar pantalla de carga
    if (_searching) {
      return Scaffold(
        backgroundColor: const Color(0xFFECF0D5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Color(0xFF7BA238)),
              SizedBox(height: 20),
              Text(
                "Buscando servidor EZBar...",
                style: TextStyle(color: Color(0xFF4A4025), fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Si no encuentra el servidor, mostrar error y botón de reintentar
    if (!_found) {
      return Scaffold(
        backgroundColor: const Color(0xFFECF0D5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "No se encontró el servidor EZBar",
                style: TextStyle(color: Color(0xFF4A4025), fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Asegúrate de estar en la misma red Wi-Fi",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _startDiscovery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BA238),
                ),
                child: const Text("Reintentar"),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _showManualConfigDialog,
                child: const Text(
                  "Configurar IP Manual",
                  style: TextStyle(color: Color(0xFF4A4025)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si encuentra, mostrar app normal
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instancia del servicio

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final RegExp usernameRegex = RegExp(r'^(?=.{3,})([a-zA-Z0-9_]+)$');
  final RegExp passwordRegex = RegExp(r'^.{8,}$');

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectando...'),
          backgroundColor: Color(0xFF7BA238),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        final response = await _apiService.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (response['status'] == 'OK') {
          // Login exitoso
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Login exitoso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Aquí podrías guardar el token si lo necesitas para futuras peticiones
          // final token = response['data']['token'];

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaPrincipal(),
              ),
            );
          });
        } else {
          // Error controlado (aunque el catch debería atraparlo si lanza excepción)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // Limpiar el mensaje de la excepción para que sea amigable
        // e.toString() suele ser "Exception: Mensaje"
        final mensaje = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 90),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BA238),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A4025).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4025),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Nombre de usuario...',
                          prefixIcon: Icon(
                            Icons.person_outlined,
                            color: Color(0xFF4A4025),
                          ),
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
                              color: Color(0xFFECF0D5),
                              width: 2.2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa tu usuario';
                          }
                          if (!usernameRegex.hasMatch(value)) {
                            return 'Usuario inválido (mín. 3 caracteres, solo letras, números y _)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Contraseña...',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFF4A4025),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4A4025),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFECF0D5),
                              width: 2.2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la contraseña';
                          }
                          if (!passwordRegex.hasMatch(value)) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A4025),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFECF0D5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECF0D5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4A4025), width: 6),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'logo_bueno.png',
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
