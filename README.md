# 📱 EZBar Frontend

<div align="center">
  <strong>Sistema de gestión digital para hostelería</strong>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Características Principales](#características-principales)
3. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
4. [Tecnologías Utilizadas](#tecnologías-utilizadas)
5. [Requisitos Previos](#requisitos-previos)
6. [Instalación y Configuración](#instalación-y-configuración)
7. [Ejecución de la Aplicación](#ejecución-de-la-aplicación)
8. [Estructura del Proyecto](#estructura-del-proyecto)
9. [Funcionalidades Implementadas](#funcionalidades-implementadas)
10. [Guías de Desarrollo](#guías-de-desarrollo)
11. [Testing](#testing)
12. [Documentación Adicional](#documentación-adicional)
13. [Autores](#autores)

---

## 📖 Descripción General

**EZBar Frontend** es una aplicación móvil desarrollada en **Flutter** que permite a camareros y personal de hostelería gestionar pedidos y mesas de forma digital desde sus dispositivos móviles (Android e iOS).

La aplicación sustituye el método tradicional de libreta y bolígrafo por una solución digital que:
- ✅ Reduce tiempos de espera
- ✅ Minimiza errores en pedidos
- ✅ Facilita la gestión de zonas y mesas
- ✅ Mejora la comunicación entre salón y cocina/barra
- ✅ Ofrece una interfaz intuitiva y rápida

**Estado**: 🚀 Versión 1.0.0 (Alpha)  
**Plataformas**: Android, iOS, Web, Windows, Linux, macOS

---

## ✨ Características Principales

### 🔐 Autenticación y Sesiones
- Inicio de sesión con credenciales
- Gestión de tokens JWT
- Persistencia de sesión
- Cierre de sesión seguro

### 🗺️ Gestión de Zonas y Mesas
- Selector de zonas (Terraza, Barra, Comedor, etc.)
- Mapa visual de mesas
- Estados de mesa (Libre, Ocupada, Pendiente de pago)
- Actualización en tiempo real

### 🛒 Gestión de Pedidos
- Visualización de carta de productos
- Añadir/eliminar productos al pedido
- Modificar cantidades
- Añadir notas especiales
- Enviar pedidos a cocina/barra
- Historial de pedidos

### 💳 Cierre de Mesa
- Cálculo de totales
- Gestión de pagos
- Liberación de mesa

### 🌍 Localización Multiidioma
- Soporte para Español, Inglés y Francés
- Cambio dinámico de idioma
- Persistencia de preferencia de idioma

### 🎨 Personalización Visual
- Selector de temas (Light/Dark)
- Configuración de UI
- Persistencia de preferencias

### 📱 Almacenamiento Local
- Base de datos SQLite
- Sincronización offline
- Caché de datos

---

## 🏗️ Arquitectura del Proyecto

### Comunicación del Sistema

```
┌─────────────────┐
│  EZBar Frontend │ (Flutter)
│   (Este Repo)   │
└────────┬────────┘
         │
    ┌────▼────┐
    │ API     │
    │Node.js  │
    └────┬────┘
         │
┌────────▼────────┐
│ Backend Java    │
│ (Lógica Negocio)│
└────────┬────────┘
         │
┌────────▼────────┐
│  Base de Datos  │
│   PostgreSQL    │
└─────────────────┘
```

### Estructura en Capas

- **Presentación (UI)**: Pantallas y widgets
- **Estado**: Providers (Pattern state management)
- **Servicios**: Lógica de negocio y comunicación
- **Modelos**: Estructuras de datos
- **Configuración**: Constantes y settings

---

## 🛠️ Tecnologías Utilizadas

| Categoría | Tecnología | Versión |
|-----------|-----------|---------|
| **Framework** | Flutter | 3.0+ |
| **Lenguaje** | Dart | 3.0+ |
| **State Management** | Provider | 6.1.1 |
| **HTTP Client** | http | 1.1.0 |
| **Base de Datos Local** | SQLite | 2.3.0 |
| **Almacenamiento** | SharedPreferences | 2.3.2 |
| **Galería de Imágenes** | image_picker | 1.0.7 |
| **Logging** | logger | 2.4.0 |
| **Localización** | flutter_localizations | 3.0+ |
| **Icons** | Cupertino Icons | 1.0.8 |

---

## 📋 Requisitos Previos

Antes de ejecutar el Frontend, asegúrate de tener instalado:

- **Flutter 3.0+** ([Descargar](https://flutter.dev/docs/get-started/install))
- **Dart SDK** (incluido con Flutter)
- **Git** para clonar el repositorio
- **Android Studio** o **VS Code** con extensión de Flutter
- **Emulador Android/iOS** o dispositivo físico
- **Node.js** (para ejecutar la API)
- **Java** (para ejecutar el Backend)

### Verificar Instalación

```bash
flutter --version
dart --version
```

---

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone https://github.com/Monti1751/EZBar_Frontend.git
cd EZBar_Frontend
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Archivos de Localización (Opcional)

Si modificas los archivos de traducción, regenera los archivos:

```bash
flutter gen-l10n
```

### 4. Configurar Conexión a API

Abre [lib/config/app_constants.dart](lib/config/app_constants.dart) y configura:

```dart
static const String apiUrl = 'http://tu-api.com';
static const String apiPort = '3000';
```

### 5. (Opcional) Generar Iconos

Si necesitas regenerar los iconos:

```bash
flutter pub run flutter_launcher_icons
```

---

## ▶️ Ejecución de la Aplicación

### Listar Dispositivos Disponibles

```bash
flutter devices
```

### Ejecutar en Android

```bash
flutter run -d android
```

### Ejecutar en iOS

```bash
flutter run -d ios
```

### Ejecutar en Web

```bash
flutter run -d web
```

### Ejecutar en Windows

```bash
flutter run -d windows
```

### Ejecutar en Modo Release

```bash
flutter run --release
```

### Ejecutar con Logs

```bash
flutter run --verbose
```

---

## 📁 Estructura del Proyecto

```
EZBar_Frontend/
├── lib/
│   ├── main.dart                 # Punto de entrada de la app
│   ├── config/                   # Configuración y constantes
│   │   └── app_constants.dart
│   ├── l10n/                     # Localización (JSON)
│   │   ├── es.json               # Español
│   │   ├── en.json               # Inglés
│   │   └── fr.json               # Francés
│   ├── models/                   # Modelos de datos
│   ├── pantallas/                # Pantallas/Páginas
│   │   ├── pantalla_principal.dart
│   │   ├── settings_menu.dart
│   │   ├── carta_page.dart
│   │   └── ...
│   ├── providers/                # State Management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── visual_settings_provider.dart
│   │   ├── localization_provider.dart
│   │   └── ...
│   ├── services/                 # Servicios (API, BD, etc)
│   │   ├── hybrid_data_service.dart
│   │   ├── localization_service.dart
│   │   ├── logger_service.dart
│   │   └── ...
│   └── widgets/                  # Componentes reutilizables
│       ├── language_selector.dart
│       └── ...
├── android/                      # Configuración Android
├── ios/                          # Configuración iOS
├── web/                          # Configuración Web
├── windows/                      # Configuración Windows
├── linux/                        # Configuración Linux
├── macos/                        # Configuración macOS
├── test/                         # Tests
├── pubspec.yaml                  # Dependencias y configuración
├── analysis_options.yaml         # Análisis estático
└── README.md                     # Este archivo
```

---

## 🎯 Funcionalidades Implementadas

### ✅ Completadas

- [x] Sistema de autenticación (Login)
- [x] Selector de zonas
- [x] Mapa de mesas
- [x] Gestión de pedidos
- [x] Cierre de mesa
- [x] Localización multiidioma (ES, EN, FR)
- [x] Temas visuales (Light/Dark)
- [x] Almacenamiento local (SQLite)
- [x] Sincronización offline
- [x] Logging avanzado
- [x] Gestión de sesiones/tokens

### 🔄 En Progreso

- [ ] Optimizaciones de rendimiento
- [ ] Nuevas pantallas de administración
- [ ] Reportes y estadísticas

### 📋 Pendiente

- [ ] Notificaciones push
- [ ] QR codes para mesas
- [ ] Integración con impresoras

---

## 📚 Guías de Desarrollo

### Guía de Localización

Para añadir nuevos idiomas o traducir cadenas, consulta:
📖 [LOCALIZATION_GUIDE.md](LOCALIZATION_GUIDE.md)

### Guía de Integración

Para integrar nuevas funcionalidades o módulos:
📖 [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

### Manual del Usuario

Para documentación del usuario final:
📖 [manual/MANUAL_USUARIO.md](manual/MANUAL_USUARIO.md)

### Resumen de Implementación

Detalles técnicos de características implementadas:
📖 [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

---

## 🧪 Testing

### Ejecutar Todos los Tests

```bash
flutter test
```

### Ejecutar Tests con Coverage

```bash
flutter test --coverage
```

En Windows, ejecuta:

```bash
./run_tests_with_coverage.bat
```

### Guía de Testing

Para instrucciones detalladas sobre testing:
📖 [GUIA_TESTEO.md](GUIA_TESTEO.md)

---

## 📄 Documentación Adicional

- 🔍 [analysis_options.yaml](analysis_options.yaml) - Configuración de análisis estático
- 📝 [CHANGELOG.md](CHANGELOG.md) - Historial de cambios
- 🚀 [Manual del Usuario](manual/MANUAL_USUARIO.md) - Guía para usuarios finales

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Para mantener la calidad del código:

1. Crea una rama para tu feature: `git checkout -b feature/nombre-feature`
2. Realiza commits descriptivos
3. Asegúrate de que los tests pasen
4. Abre un Pull Request

---

## 👨‍💻 Autores

- **Monti** - Desarrollador Frontend
- Equipo de Desarrollo de EZBar

---

## 📞 Soporte y Contacto

Para reportar bugs o sugerencias:
- 📧 Email: [contacto@ezbar.com]
- 🐛 Issues: [GitHub Issues](https://github.com/Monti1751/EZBar_Frontend/issues)

---

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

**Última actualización**: 15 de mayo de 2026  
- Mejorar la coordinación entre camareros y cocina/barra.  
- Ofrecer una interfaz clara y fácil de usar incluso en momentos de alta carga de trabajo.
  
## 4. Estado del Proyecto

El Frontend de EZBar se encuentra actualmente en **versión Alpha**, lo que significa que está en una fase temprana de desarrollo y pruebas.  
Durante esta etapa se están validando las funcionalidades principales y la correcta comunicación con la API Node.js y el Backend Java.

### Funcionalidades en Estado Alpha

- Interfaz funcional para la gestión de zonas y mesas.  
- Sistema básico de autenticación.  
- Creación y edición de pedidos.  
- Comunicación estable con la API Node.js.  
- Actualización del estado de mesas en tiempo real (según implementación actual).

### Próximos Objetivos

- Mejoras en la interfaz de usuario y experiencia de uso.  
- Optimización del rendimiento en dispositivos de gama baja.  
- Implementación de nuevas pantallas y flujos.  
- Preparación para una futura **versión Beta**, más estable y completa.

> El proyecto está en desarrollo activo, por lo que se esperan cambios frecuentes en la estructura y funcionamiento del Frontend.

## 5. Autores

Este módulo Frontend forma parte del proyecto completo **EZBar**, desarrollado por:

- **Miguel Tomás**    
  - GitHub: [ismigue23](https://github.com/ismigue23)

- **Francisco Montesinos**    
  - GitHub: [Monti1751](https://github.com/Monti1751)

- **Miguel Jiménez**  
  - GitHub: [MiguelJimenezSerrano](https://github.com/MiguelJimenezSerrano)

- **Miguel Duque**  
  - GitHub: [El-Mig](https://github.com/El-Mig)  

> Para más información sobre el proyecto completo, consulta el README principal del repositorio.
