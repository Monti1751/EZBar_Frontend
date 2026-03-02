# Guía de Integración - Sistema de Localización

## 1. Actualizar pubspec.yaml

✅ **Ya está actualizado** - Se añadió la carpeta `lib/l10n/` a los assets.

## 2. Actualizar main.dart

✅ **Ya está actualizado** con:
- Inicialización de `LocalizationService()`
- Configuración de `localizationsDelegates`
- Configuración de `supportedLocales`

## 3. Actualizar Providers

En `lib/main.dart`, envuelve tu app con el `LocalizationProvider`:

**Opción A: Si quieres cambiar el idioma en cualquier parte de la app**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VisualSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalizationProvider(),
        ),
      ],
      child: const LogIn(),
    ),
  );
}
```

## 4. Usar en tus Pantallas

### En cualquier widget StatelessWidget:

```dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings_header')),
      ),
      body: Text(localizations.translate('welcome')),
    );
  }
}
```

### En tu settings_menu.dart:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_settings_tile.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings = Provider.of<VisualSettingsProvider>(context);

    // ... tu código actual ...

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ... tus otros widgets ...
            
            // Añade el selector de idioma
            LanguageSettingsOption(
              fontSize: fontSize,
              textColor: textoGeneral,
              tileColor: fondo,
            ),
            
            // ... resto de tu menú ...
          ],
        ),
      ),
    );
  }
}
```

## 5. Usar el Selector de Idioma en tu AppBar o TopBar

```dart
import '../widgets/language_selector.dart';

AppBar(
  title: Text(localizations.translate('app_title')),
  actions: [
    LanguageSelector(),
    // ... otros actions ...
  ],
)
```

## 6. Cambiar Idioma Programáticamente

```dart
import 'package:provider/provider.dart';
import 'providers/localization_provider.dart';

// En cualquier parte de tu código:
Provider.of<LocalizationProvider>(context, listen: false)
    .setLocale(const Locale('en')); // Cambiar a Inglés
```

## 7. Acceder a las Claves de Traducción Disponibles

Todas estas claves están disponibles en los archivos JSON:

### Configuración Visual
- `settings_title` - "Ajustes visuales"
- `dark_mode` - "Modo oscuro"
- `color_blind_mode` - "Modo daltonismo"
- `font_size` - "Tamaño letra"

### Idioma
- `change_language` - "Cambiar idioma"
- `select_language` - "Seleccionar idioma"
- `language_changed` - "Idioma cambiado"

### Autenticación
- `login` - "Iniciar sesión"
- `logout` - "Cerrar sesión"
- `username_hint` - "Nombre de usuario..."
- `password_hint` - "Contraseña..."
- `please_enter_username` - "Por favor, ingresa tu usuario"
- `please_enter_password` - "Por favor, ingresa la contraseña"
- `login_success` - "¡Login exitoso!"

### Conexión
- `manual_ip_title` - "Configurar IP Manual"
- `searching_server` - "Buscando servidor EZBar..."
- `server_not_found` - "No se encontró el servidor EZBar"
- `cannot_connect` - "No se pudo conectar. Verifica la IP y el Firewall."

### Menú y Platos
- `menu_plus` - "Carta +"
- `create_edit_dish` - "Crear/Editar Plato"
- `dish_name_hint` - "Nombre del plato"
- `product_default` - "Producto"

### Mesas
- `table_name_hint` - "Nombre de la mesa"
- `status_libre` - "LIBRE"
- `status_reservada` - "RESERVADA"
- `status_ocupada` - "OCUPADA"

### Zonas
- `add_zone` - "Agregar Zona"
- `zone_name_hint` - "Nombre de la zona"
- `add_section` - "Agregar sección..."

Y muchas más... Todas están disponibles en `lib/l10n/*.json`

## 8. Ejemplo Completo - settings_menu.dart Mejorado

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/visual_settings_provider.dart';
import '../widgets/language_settings_tile.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final localizations = AppLocalizations.of(context);

    final Color fondo = settings.darkMode ? Colors.black : Colors.white;
    final Color encabezado = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;
    final double fontSize = settings.currentFontSize;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: encabezado,
              child: Text(
                localizations.translate('settings_header'),
                style: TextStyle(
                  fontSize: fontSize + 6,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Selector de Idioma
                  LanguageSettingsOption(
                    fontSize: fontSize,
                    textColor: textoGeneral,
                    tileColor: fondo,
                  ),
                  
                  const Divider(),
                  
                  // Resto de tu menú...
                  // ListTile(
                  //   title: Text(localizations.translate('dark_mode')),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 9. Testing - Verificar que Todo Funciona

En `test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:log_in/main.dart';
import 'package:log_in/services/localization_service.dart';
import 'package:log_in/providers/localization_provider.dart';

void main() {
  testWidgets('LocalizationService loads correctly', (WidgetTester tester) async {
    final service = LocalizationService();
    await service.init();

    expect(service.supportedLanguages, contains('es'));
    expect(service.supportedLanguages, contains('en'));
    expect(service.supportedLanguages, contains('fr'));
  });

  testWidgets('Language changes work', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<LocalizationProvider>(
              builder: (context, provider, _) {
                return Text(provider.currentLocale.languageCode);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('es'), findsOneWidget);
  });
}
```

## Conclusión

El sistema está completamente configurado. Solo necesitas:

1. ✅ Actualizar `main.dart` para envolver la app con `LocalizationProvider` (si deseas cambiar idioma en tiempo real)
2. ✅ Usar `AppLocalizations.of(context).translate('clave')` en tus widgets
3. ✅ Incorporar los widgets de selector de idioma en tu menú de settings

¡Listo para usar! 🎉
