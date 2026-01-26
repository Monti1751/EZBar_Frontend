import 'package:flutter/material.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';

//Pantalla de prueba para ver un plato en detalle (sin posibilidad de editar)
class VerPlato {
  String nombre;
  double precio;
  File? imagen;
  List<String> ingredientes;
  List<String> extras;
  List<String> alergenos; // Nuevo campo

  VerPlato({
    required this.nombre,
    required this.precio,
    this.imagen,
    this.ingredientes = const [],
    this.extras = const [],
    this.alergenos = const ["Gluten", "Lácteos"], // Ejemplo por defecto
  });
}

class PlatoDetallePage extends StatelessWidget {
  final VerPlato plato;

  const PlatoDetallePage({super.key, required this.plato});

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF7BA238);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('create_edit_dish')),
        backgroundColor: colorPrimario,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen Estática (Sin cambios posibles)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: plato.imagen != null
                    ? DecorationImage(
                        image: FileImage(plato.imagen!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: plato.imagen == null
                  ? const Icon(Icons.fastfood, size: 80, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 20),

            // 2. Nombre, Información y Precio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        plato.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Icono de información para alérgenos
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          _mostrarAlergenos(context, plato.alergenos);
                        },
                      ),
                    ],
                  ),
                ),
                Text(
                  "${plato.precio.toStringAsFixed(2)}€",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorPrimario,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // 3. Sección de Ingredientes (Solo lectura)
            const Text(
              "Ingredientes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: plato.ingredientes
                  .map(
                    (i) => Chip(
                      label: Text(i),
                      backgroundColor: colorPrimario.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 20),

            // 4. Sección de Extras (Solo lectura)
            if (plato.extras.isNotEmpty) ...[
              const Text(
                "Extras disponibles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: plato.extras
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.add_circle_outline,
                          color: colorPrimario,
                        ),
                        title: Text(e),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 30),

            // Botón de Volver
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimario,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Volver a la carta",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el desplegable de alérgenos
  void _mostrarAlergenos(BuildContext context, List<String> alergenos) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Información de Alérgenos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              alergenos.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      children: alergenos
                          .map(
                            (a) => Chip(
                              avatar: const Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                              ),
                              label: Text(a),
                              backgroundColor: Colors.orange[100],
                            ),
                          )
                          .toList(),
                    )
                  : Text(AppLocalizations.of(context).translate('product_default')),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
