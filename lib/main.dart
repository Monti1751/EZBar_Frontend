import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'package:provider/provider.dart';
import 'visual_settings_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VisualSettingsProvider(),
      child: const LogIn(),
    ),
  );
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    return MaterialApp(
      title: 'EZBar',
      debugShowCheckedModeBanner: false,

      // 🔥 Aquí aplicamos el modo oscuro/claro
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,

      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFECF0D5),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFECF0D5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238), width: 2),
          ),
        ),
        textTheme: settings.smallFont
            ? const TextTheme(
                bodyMedium: TextStyle(fontSize: 14),
                titleLarge: TextStyle(fontSize: 18),
              )
            : const TextTheme(
                bodyMedium: TextStyle(fontSize: 18),
                titleLarge: TextStyle(fontSize: 24),
              ),
      ),

      // Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238), width: 2),
          ),
        ),
        textTheme: settings.smallFont
            ? const TextTheme(
                bodyMedium: TextStyle(fontSize: 14),
                titleLarge: TextStyle(fontSize: 18),
              )
            : const TextTheme(
                bodyMedium: TextStyle(fontSize: 18),
                titleLarge: TextStyle(fontSize: 24),
              ),
      ),

      home: const LoginPage(),
    );
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

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectando...'),
          backgroundColor: Color(0xFF7BA238),
          duration: Duration(seconds: 2),
        ),
      );

      // Espera 2 segundos para mostrar el mensaje y luego cambia de pantalla
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
        );
      });
    }
  }

  final RegExp usernameRegex = RegExp(r'^(?=.{3,})([a-zA-Z0-9_]+)$');
  final RegExp passwordRegex = RegExp(r'^.{8,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Contenedor del formulario
              Container(
                margin: const EdgeInsets.only(top: 90),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BA238),
                  borderRadius: BorderRadius.circular(20),
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
                        "Bienvenido",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4025),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario...',
                          prefixIcon: Icon(Icons.person_outlined, color: Color(0xFF4A4025)),
                        ),
                        validator: (value) {
                          return (value != null && usernameRegex.hasMatch(value))
                              ? null
                              : 'Usuario inválido';
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña...',
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4A4025)),
                        ),
                        validator: (value) {
                          return (value != null && passwordRegex.hasMatch(value))
                              ? null
                              : 'Contraseña inválida';
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
                            style: TextStyle(fontSize: 18, color: Color(0xFFECF0D5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Logo superpuesto
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECF0D5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A4025),
                    width: 6,
                  ),
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
