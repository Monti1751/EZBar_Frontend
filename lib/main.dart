import 'package:flutter/material.dart';
import 'pantalla_principal.dart'; // Se importa la pantalla principal para la navegación posterior al login.

void main() {
  runApp(const LogIn()); // Se inicializa la aplicación ejecutando el widget LogIn.
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZBar', // Título de la aplicación que aparece en la barra del sistema.
      debugShowCheckedModeBanner: false, // Elimina la bandera de depuración en la esquina superior derecha.
      theme: ThemeData( // Establece el tema de la aplicación.
        primarySwatch: Colors.green, // Color principal de la aplicación (verde).
        scaffoldBackgroundColor: const Color(0xFFECF0D5), // Color de fondo del scaffold.
        inputDecorationTheme: InputDecorationTheme( // Estilos para los campos de texto.
          filled: true,
          fillColor: const Color(0xFFECF0D5), // Color de fondo de los campos de texto.
          border: OutlineInputBorder( // Estilo del borde de los campos de texto.
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238)), // Color del borde.
          ),
          focusedBorder: OutlineInputBorder( // Estilo del borde cuando el campo tiene el foco.
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7BA238), width: 2), // Borde más grueso al enfocarse.
          ),
        ),
      ),
      home: const LoginPage(), // Pantalla de inicio, que será LoginPage.
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario.
  final TextEditingController _usernameController = TextEditingController(); // Controlador para el campo de nombre de usuario.
  final TextEditingController _passwordController = TextEditingController(); // Controlador para el campo de contraseña.

  void _login() {
    if (_formKey.currentState!.validate()) { // Valida los campos del formulario.
      // Muestra un Snackbar con el mensaje 'Conectando...'
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectando...'),
          backgroundColor: Color(0xFF7BA238),
          duration: Duration(seconds: 2), // Duración de 2 segundos.
        ),
      );

      // Espera 2 segundos y luego navega a la pantalla principal.
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()), // Navega a la pantalla principal.
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Permite desplazamiento cuando el contenido es grande.
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding para el formulario.
          child: Stack( // Stack para superponer elementos (formulario y logo).
            alignment: Alignment.topCenter, // Alinea los elementos en el centro superior.
            children: [
              // Contenedor del formulario de login
              Container(
                margin: const EdgeInsets.only(top: 90), // Desplaza el contenedor hacia abajo.
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24), // Padding interno del contenedor.
                decoration: BoxDecoration(
                  color: const Color(0xFF7BA238), // Fondo del formulario (color verde).
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados.
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A4025).withOpacity(0.2), // Sombra suave.
                      blurRadius: 10, // Radio de desenfoque de la sombra.
                      offset: const Offset(0, 4), // Desplazamiento de la sombra.
                    ),
                  ],
                ),
                child: Form( // Formulario que contiene los campos de texto.
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Toma el tamaño mínimo posible en el eje vertical.
                    children: [
                      const SizedBox(height: 6), // Espaciado superior.
                      const Text(
                        "Bienvenido", // Título de bienvenida.
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4025), // Color del texto.
                        ),
                      ),
                      const SizedBox(height: 30), // Espaciado entre el título y el primer campo de texto.
                      // Campo de texto para el nombre de usuario
                      TextFormField(
                        controller: _usernameController, // Controlador para el nombre de usuario.
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario...', // Texto dentro del campo de texto.
                          prefixIcon: Icon(Icons.person_outlined, color: Color(0xFF4A4025)), // Ícono de usuario.
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa tu usuario'; // Mensaje de error si está vacío.
                          }
                          return null; // Si es válido, retorna null.
                        },
                      ),
                      const SizedBox(height: 16), // Espaciado entre los campos de texto.
                      // Campo de texto para la contraseña
                      TextFormField(
                        controller: _passwordController, // Controlador para la contraseña.
                        obscureText: true, // Hace que el texto ingresado sea oculto (contraseña).
                        decoration: const InputDecoration(
                          labelText: 'Contraseña...', // Texto dentro del campo de texto.
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4A4025)), // Ícono de candado.
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la contraseña'; // Mensaje de error si está vacío.
                          }
                          if (value.length < 8) {
                            return 'Debe tener al menos 8 caracteres'; // Mensaje de error si la contraseña es corta.
                          }
                          return null; // Si es válido, retorna null.
                        },
                      ),
                      const SizedBox(height: 24), // Espaciado inferior.
                      SizedBox(
                        width: double.infinity, // Hace que el botón ocupe todo el ancho disponible.
                        child: ElevatedButton(
                          onPressed: _login, // Acción que se ejecuta al presionar el botón.
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A4025), // Color del fondo del botón.
                            padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertical del botón.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Bordes redondeados del botón.
                            ),
                          ),
                          child: const Text(
                            'Iniciar sesión', // Texto del botón.
                            style: TextStyle(fontSize: 18, color: Color(0xFFECF0D5)), // Estilo del texto del botón.
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Logo superpuesto encima del formulario
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECF0D5), // Color de fondo del logo.
                  shape: BoxShape.circle, // Forma circular del logo.
                  border: Border.all(
                    color: const Color(0xFF4A4025), // Color del borde alrededor del logo.
                    width: 6, // Ancho del borde.
                  ),
                ),
                padding: const EdgeInsets.all(8), // Padding interno del contenedor del logo.
                child: ClipOval(
                  child: Image.asset(
                    'logo_bueno.png', // Imagen del logo (asegúrate de que la imagen esté en el directorio adecuado).
                    height: 130, // Altura del logo.
                    width: 130, // Ancho del logo.
                    fit: BoxFit.cover, // Ajusta la imagen para cubrir el área del círculo.
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
