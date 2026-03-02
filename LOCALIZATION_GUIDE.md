# Sistema de Localización Multiidioma - EZBar Frontend

## Descripción

Se ha implementado un sistema completo de soporte multiidioma para la aplicación Flutter. El sistema incluye soporte para **Español**, **Inglés** y **Francés**, con la posibilidad de añadir más idiomas fácilmente.

## Estructura

### Archivos de Configuración

- **`lib/l10n/es.json`** - Traducciones al español
- **`lib/l10n/en.json`** - Traducciones al inglés
- **`lib/l10n/fr.json`** - Traducciones al francés
- **`lib/l10n/app_localizations.dart`** - Clase principal de localización

### Servicios

- **`lib/services/localization_service.dart`** - Servicio singleton para gestionar las traducciones
- **`lib/providers/localization_provider.dart`** - Provider de Provider para cambiar idioma en tiempo real

### Widgets

- **`lib/widgets/language_selector.dart`** - Componentes UI para seleccionar idioma
  - `LanguageSelector` - Botón selector de idioma
  - `LanguageSelectorDialog` - Diálogo para seleccionar idioma

## Cómo Usar

### 1. Añadir una Nueva Clave de Traducción

Abre los archivos JSON en `lib/l10n/` y añade la nueva clave a todos los idiomas:

**es.json:**
```json
{
  "welcome_message": "Bienvenido a EZBar"
}
```

**en.json:**
```json
{
  "welcome_message": "Welcome to EZBar"
}
```

**fr.json:**
```json
{
  "welcome_message": "Bienvenue dans EZBar"
}
```

### 2. Usar las Traducciones en tu Código

```dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Text(localizations.translate('welcome_message'));
  }
}
```

### 3. Cambiar el Idioma

```dart
import 'package:provider/provider.dart';
import 'providers/localization_provider.dart';

// Cambiar a Inglés
Provider.of<LocalizationProvider>(context, listen: false)
    .setLocale(const Locale('en'));

// Cambiar a Francés
Provider.of<LocalizationProvider>(context, listen: false)
    .setLocale(const Locale('fr'));

// Cambiar a Español
Provider.of<LocalizationProvider>(context, listen: false)
    .setLocale(const Locale('es'));
```

### 4. Usar el Selector de Idioma en la UI

```dart
import 'widgets/language_selector.dart';

// Como botón en AppBar o TopBar
AppBar(
  actions: [
    LanguageSelector(),
  ],
)

// Como diálogo
showDialog(
  context: context,
  builder: (context) => const LanguageSelectorDialog(),
)
```

## Características

✅ **Soporte para múltiples idiomas** - Fácil de extender
✅ **Persistencia** - El idioma seleccionado se guarda en SharedPreferences
✅ **Actualización en tiempo real** - Usa Provider para cambios dinámicos
✅ **Widgets UI listos** - Componentes selector de idioma incluidos
✅ **Fallback automático** - Si falta una traducción, usa la clave como fallback
✅ **Soporta la localización de Flutter** - Compatible con GlobalMaterialLocalizations

## Añadir un Nuevo Idioma

Para añadir un nuevo idioma (p.ej., Portugués):

1. Crea un nuevo archivo `lib/l10n/pt.json` con todas las traducciones
2. Actualiza los archivos:
   - `lib/services/localization_service.dart` - Añade 'pt' a `supportedLanguages` y a `languageNames`
   - `lib/l10n/app_localizations.dart` - Añade 'pt' a la lista de idiomas soportados
   - `lib/pubspec.yaml` - Actualiza si es necesario

## Ejemplo Completo

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/localization_provider.dart';
import 'widgets/language_selector.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings_header')),
        actions: [LanguageSelector()],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(localizations.translate('select_language')),
            trailing: LanguageSelector(),
            onTap: () => showDialog(
              context: context,
              builder: (context) => const LanguageSelectorDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Nota Importante

La actualización del idioma requiere que `main.dart` esté correctamente configurado con:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService().init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => VisualSettingsProvider(),
      child: const LogIn(),
    ),
  );
}
```

Y en la clase `LogIn` (MaterialApp):

```dart
locale: localizationService.currentLocale,
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: localizationService.supportedLocales,
```
