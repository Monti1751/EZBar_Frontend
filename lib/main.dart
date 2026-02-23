import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'services/logger_service.dart';
import 'config/app_constants.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'pantallas/pantalla_principal.dart';
import 'providers/visual_settings_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/auth_provider.dart';
import 'services/hybrid_data_service.dart';
import 'services/token_manager.dart';
import 'l10n/app_localizations.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Activar modo inmersivo en dispositivos móviles (ocultar barra de estado y navegación)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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

  // Cargar token al iniciar la app
  final tokenManager = TokenManager();
  await tokenManager.loadToken();

  // Inicializar AuthProvider y cargar rol de cache
  final authProvider = AuthProvider();
  await authProvider.initialize();

  // Verificar token con el backend si existe para asegurar rol actualizado
  final token = tokenManager.getTokenSync();
  if (token != null) {
    print('📡 Verificando sesión con el backend...');
    final dataService = HybridDataService();
    try {
      final verifyResponse = await dataService.verificarToken();
      if (verifyResponse != null && verifyResponse['status'] == 'OK') {
        final backendRole = verifyResponse['data']['usuario']['rol'];
        await authProvider.syncRoleWithBackend(backendRole);
        print('✅ Sesión verificada. Rol: $backendRole');
      } else {
        print('⚠️ Sesión inválida o expirada. Limpiando token.');
        await tokenManager.clearToken();
        await authProvider.logout();
      }
    } catch (e) {
      print('⚠️ Error al verificar sesión (posiblemente offline): $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => VisualSettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const LogIn(),
    ),
  );
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final localization = Provider.of<LocalizationProvider>(context);

    return MaterialApp(
      navigatorKey: globalNavigatorKey,
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
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
        ),
      ),
      builder: (context, child) {
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Deslizamiento de derecha a izquierda rápido (velocidad negativa)
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -300) {
              if (globalNavigatorKey.currentState != null &&
                  globalNavigatorKey.currentState!.canPop()) {
                globalNavigatorKey.currentState!.pop();
              }
            }
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
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
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('login_success')),
              backgroundColor: AppConstants.successColor,
            ),
          );

          // Leer el rol desde la respuesta del servidor si está disponible
          String rol = 'usuario'; // Por defecto
          if (response['data'] != null &&
              response['data']['usuario'] != null &&
              response['data']['usuario']['rol'] != null) {
            rol = response['data']['usuario']['rol'];
          }

          // Guardar el rol en el State global
          Provider.of<AuthProvider>(context, listen: false).setRole(rol);

          // Cargar el token
          final token = response['data']?['token'] ?? response['token'];
          if (token != null && token.isNotEmpty) {
            await TokenManager().saveToken(token);
            print('✅ Token guardado: $token');
          }

          // Cargar datos iniciales en SQLite
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
          // Si el status no es OK, lanzamos excepción para que la capture el catch
          throw Exception('Credenciales incorrectas');
        }
      } catch (e) {
        if (!mounted) return;
        final errorMsg = e.toString();
        String snackBarMsg =
            AppLocalizations.of(context).translate('connection_error');

        // Determinar si es un error de credenciales
        if (errorMsg.contains('Credenciales incorrectas')) {
          snackBarMsg =
              AppLocalizations.of(context).translate('incorrect_credentials');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(snackBarMsg),
              backgroundColor: AppConstants.errorColor),
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
                      color: AppConstants.darkBrown.withOpacity(0.2),
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
