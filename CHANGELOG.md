# Changelog
## Versión 0.8.0 (23-2-2026)

### Añadido
* Contenedores arrastrables.
* Ocultación de los botones de android.
* Volver a la pantalla anterior desplazando hacia la izquierda.
* Se ha añadido la pantalla de creación y gestión de usuarios.
* Se ha implementado SQLite como cache.
* Se ha añadido vista de Usuario.
* Ahora en la apk tiene el nombre correcto y un icono personalizado.

### Corregido
* Ahora se muestran los platos en la pantalla de carta y de cuenta.
* Se ha arreglado el conflicto con SQLite.
* Todos los iconos ahora son de color negro.
* Se ha corregido el modo oscuro en su totalidad.
  
## Versión 0.7.0 (9-2-2026)

### Añadido
* Lógica del botón de guardado.
* Implementación de estado de bloqueo del botón: el botón "Agregar" ahora se desactiva durante el guardado y solo se habilita al detectar cambios reales.

### Corregido
* Mejora de persistencia de imágenes.
* Se actualizó PlatoEditorPage para manejar correctamente la selección de imágenes con XFile y codificación Base64.
* Mejora del widget de imagen para manejar archivos locales, URLs y blobs Base64 de forma consistente.
* Corrección de posible fallo por ID nulo en el callback de actualización de productos.

## Versión 0.5.0 (15-12-2025)

### Añadido
* Se ha añadido la pantalla para la creación de los plato.
* Se ha añadido la pantalla para la carta y un acceso desde ajuses funcinal.
* Se ha añadido advertencia de borrado.
* Se ha añadido el botón para cambiar el idiama de la app en ajustes (aun sin funcionalidad).

### Corregido
* Se ha cambiado la funcionalidad del botón para acceder a la carta.
* Se ha cambiado el estilo visual de los estados de las mesas (Badges).
* Ajustar botón de la zona.
* Eliminar segundo bloque de añadir mesas.
* Corregir tamaño de la letra.
* Se ha cambiado los scrolls de las pantallas.
* Uniformidad en los contenedores.
* Se ha cambiado la funcinalidad del botón para regresar al menú principal.
* Se han corregido los cuadros de texto (Nuestros colores, levelText -> hintText) y que no se deformen.
* Ajustar botón carta.

## Versión 0.2.0 (30-11-2025)

### Añadido
* Se ha añadido la ventana de ajustes dentro de la ventana de mesas, igual que en el menú principal.
* Se ha creado la pantalla de las mesas en las que está la cuenta.
* Se ha conectado la pantalla de menú principal a la pantalla de mesas.
* Se ha añadido la ventana de ajustes visuales.
* Se ha eliminado "Editar platos" de los ajustes.
* Se ha añadido la clase visual_settings_provider.dart.
* Se ha añadido funcionalidad a la ventana de ajustes visuales.
* Se ha empleado la dependecia de Provider: 6.0.0.

### Corregido
* Se ha cambiado el condicional del inicio de sesión por un controlador basado en Regex.

## Versiuón 0.1.0 (17-11-2025)

### Añadido
* Se ha añadido una página de Log in.
* Se ha añadido una página de Menú principal.
* Se han añadido los ajustes.

