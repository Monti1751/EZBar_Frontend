# Memoria de Funcionalidades Postergadas

**Ubicación original:** `lib/pantallas/settings_menu.dart`
**Contexto:** Se ocultaron botones del menú de ajustes para la presentación del proyecto. Estos botones están restringidos a usuarios con rol de administrador (`auth.isAdmin`).

En el futuro, cuando se retome el desarrollo de estas características, se deben volver a integrar estos botones en la lista de opciones del `SettingsMenu`.

---

## 1. Control de Roles
Botón pensado para gestionar los roles de los empleados/usuarios del sistema (asignar permisos, cambiar roles, etc.).

**Código a restaurar:**
```dart
_menuItem(
  icon: Icons.person_pin,
  text: AppLocalizations.of(context).translate('manage_roles'),
  onTap: () {
    // TODO: Navegar a la pantalla de gestión de roles
  },
  textoColor: textoGeneral,
  fontSize: fontSize,
),
```

## 2. Editar Inventario
Botón diseñado para la gestión del stock, ingredientes y productos del almacén.

**Código a restaurar:**
```dart
_menuItem(
  icon: Icons.inventory,
  text: AppLocalizations.of(context).translate('edit_inventory'),
  onTap: () {
    // TODO: Navegar a la pantalla de gestión de inventario
  },
  textoColor: textoGeneral,
  fontSize: fontSize,
),
```

---

*Nota para el asistente: Esta carpeta (`notas_desarrollo`) sirve como base de conocimiento y registro de tareas pendientes u órdenes futuras para el proyecto.*
