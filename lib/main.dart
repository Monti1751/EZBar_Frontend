import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pantallas/pantalla_principal.dart';
import 'package:provider/provider.dart';
import 'providers/visual_settings_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/sync_provider.dart';
import 'services/hybrid_data_service.dart';
import 'l10n/app_localizations.dart';
import 'services/localization_service.dart';
import 'services/logger_service.dart';
import 'config/app_constants.dart';

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar base de datos para escritorio (Windows/Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Configurar captura de errores globales de Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    LoggerService.e('Flutter Error', details.exception, details.stack);
  };

  // Configurar captura de errores asíncronos fuera de Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.e('Asynchronous Error', error, stack);
    return true;
  };

  LoggerService.i('Iniciando aplicacion EZBar...');
  await LocalizationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VisualSettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const LogIn(),
    ),
  );
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final localization = Provider.of<LocalizationProvider>(context);

    return MaterialApp(
      title: 'EZBar',
      debugShowCheckedModeBanner: false,
      locale: localization.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: localization.localizationService.supportedLocales,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppConstants.backgroundCream,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.backgroundCream,
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
  final HybridDataService _dataService =
      HybridDataService(); // Servicio híbrido (API + SQLite)

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
          backgroundColor: AppConstants.primaryGreen,
          duration: AppConstants.snackBarShort,
        ),
      );

      try {
        final response = await _dataService.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (response['status'] == 'OK') {
          // Login exitoso
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Login exitoso!'),
              backgroundColor: AppConstants.successColor,
            ),
          );

          // Aquí podrías guardar el token si lo necesitas para futuras peticiones
          // final token = response['data']['token'];

          // Cargar datos iniciales en SQLite si es la primera vez o hay conexión
          if (!mounted) return;
          Provider.of<SyncProvider>(context, listen: false).loadInitialData();

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PantallaPrincipal(),
            ),
          );
        } else {
          // Error controlado (aunque el catch debería atraparlo si lanza excepción)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['message']}'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // Limpiar el mensaje de la excepción para que sea amigable
        // e.toString() suele ser "Exception: Mensaje"
        final mensaje = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(mensaje), backgroundColor: AppConstants.errorColor),
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
                  color: AppConstants.primaryGreen,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.darkBrown.withValues(alpha: 0.2),
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
                      Text(
                        AppLocalizations.of(context).translate('welcome'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('username_hint'),
                          prefixIcon: const Icon(
                            Icons.person_outlined,
                            color: AppConstants.darkBrown,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                            borderSide: const BorderSide(
                              color: AppConstants.darkBrown,
                              width: AppConstants.borderWidthThin,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                            borderSide: const BorderSide(
                              color: AppConstants.backgroundCream,
                              width: AppConstants.borderWidthThick,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)
                                .translate('please_enter_username');
                          }
                          if (!usernameRegex.hasMatch(value)) {
                            return AppLocalizations.of(context)
                                .translate('invalid_username');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('password_hint'),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppConstants.darkBrown,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                            borderSide: const BorderSide(
                              color: AppConstants.darkBrown,
                              width: AppConstants.borderWidthThin,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                            borderSide: const BorderSide(
                              color: AppConstants.backgroundCream,
                              width: AppConstants.borderWidthThick,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)
                                .translate('please_enter_password');
                          }
                          if (!passwordRegex.hasMatch(value)) {
                            return AppLocalizations.of(context)
                                .translate('password_min_8');
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
                            backgroundColor: AppConstants.darkBrown,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.buttonPaddingVertical),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate('login'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppConstants.backgroundCream,
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
                  color: AppConstants.backgroundCream,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppConstants.darkBrown,
                      width: AppConstants.logoBorderWidth),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'logo_bueno.PNG',
                    height: AppConstants.logoSizeLarge,
                    width: AppConstants.logoSizeLarge,
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
