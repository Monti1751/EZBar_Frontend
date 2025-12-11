import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'visual_settings_provider.dart';
import 'settings_menu.dart';

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF4A4025)),
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF4A4025),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF7BA238),
        width: 2.2,
      ),
    ),
  );
}

/// Modelo de Plato (imagen opcional, cantidades se gestionan en otra pantalla)
class Plato {
  String nombre;
  File? imagen; // Se cargará/editará en la pantalla propia del plato
  Plato({required this.nombre, this.imagen});
}

/// Modelo de Sección
class Seccion {
  String nombre;
  bool isOpen = false;
  List<Plato> platos = [];
  Seccion({required this.nombre});
}

/// Pantalla Carta
class CartaPage extends StatefulWidget {
  /// Callback opcional para integrar el botón "+" con la cuenta
  final void Function(Plato)? onAddToCuenta;

  const CartaPage({super.key, this.onAddToCuenta});

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _seccionController = TextEditingController();
  final TextEditingController _platoController = TextEditingController();

  List<Seccion> secciones = [];

  BoxDecoration _cardDecoration(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context, listen: false);
    return BoxDecoration(
      color: settings.darkMode ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black26),
    );
  }

  @override
  void dispose() {
    _seccionController.dispose();
    _platoController.dispose();
    super.dispose();
  }

  void _addPlatoToCuenta(Plato plato) {
    if (widget.onAddToCuenta != null) {
      widget.onAddToCuenta!(plato);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Añadido a la cuenta: ${plato.nombre}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;
    final double fontSize = settings.currentFontSize;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          // Barra superior
          Container(
            height: 55,
            color: barraSuperior,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: textoGeneral, size: 28),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: loginInputDecoration("Buscar...", Icons.search),
              style: TextStyle(color: textoGeneral, fontSize: fontSize),
            ),
          ),

          // Lista de secciones
          Expanded(
            child: ListView(
              children: [
                for (var seccion in secciones)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: barraSuperior,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            seccion.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              color: textoGeneral,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: "Eliminar sección",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Confirmar eliminación"),
                                      content: Text("¿Seguro que quieres eliminar la sección '${seccion.nombre}'?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              secciones.remove(seccion);
                                            });
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Icon(
                                seccion.isOpen ? Icons.expand_less : Icons.expand_more,
                                color: textoGeneral,
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() => seccion.isOpen = !seccion.isOpen);
                          },
                        ),

                        if (seccion.isOpen)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: _cardDecoration(context),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  // Añadir plato (solo nombre)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _platoController,
                                          decoration: loginInputDecoration("Nombre del plato", Icons.fastfood),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.green),
                                        tooltip: "Agregar plato",
                                        onPressed: () {
                                          if (_platoController.text.isNotEmpty) {
                                            setState(() {
                                              seccion.platos.add(Plato(nombre: _platoController.text));
                                              _platoController.clear();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Lista de platos
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        for (var plato in seccion.platos)
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                            decoration: _cardDecoration(context),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) => PlatoPage(plato: plato),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // Imagen pequeña + nombre
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          if (plato.imagen != null)
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(8),
                                                              child: Image.file(
                                                                plato.imagen!,
                                                                width: 50,
                                                                height: 50,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            )
                                                          else
                                                            Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey[300],
                                                                borderRadius: BorderRadius.circular(8),
                                                                border: Border.all(color: Colors.black12),
                                                              ),
                                                              child: const Icon(Icons.image, color: Colors.black26),
                                                            ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              plato.nombre,
                                                              style: TextStyle(fontSize: fontSize, color: textoGeneral),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Acciones: añadir a cuenta (+) y eliminar
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.add_circle, color: barraSuperior),
                                                          tooltip: "Añadir a la cuenta",
                                                          onPressed: () => _addPlatoToCuenta(plato),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                          tooltip: "Eliminar plato",
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) => AlertDialog(
                                                                title: const Text("Confirmar eliminación"),
                                                                content: Text("¿Seguro que quieres eliminar el plato '${plato.nombre}'?"),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.of(ctx).pop(),
                                                                    child: const Text("Cancelar"),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        seccion.platos.remove(plato);
                                                                      });
                                                                      Navigator.of(ctx).pop();
                                                                    },
                                                                    child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Botón para agregar sección
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: barraSuperior,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "Agregar sección...",
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
              onPressed: () {
                _seccionController.clear();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Nueva sección"),
                    content: TextField(
                      controller: _seccionController,
                      decoration: loginInputDecoration("Nombre de la sección", Icons.list),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_seccionController.text.isNotEmpty) {
                            setState(() {
                              secciones.add(Seccion(nombre: _seccionController.text));
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text("Agregar"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stub de pantalla de detalle de plato para navegar.
/// Sustitúyela por tu implementación real (imagen, descripción, precio, etc.).
class PlatoPage extends StatelessWidget {
  final Plato plato;
  const PlatoPage({super.key, required this.plato});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plato.nombre)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (plato.imagen != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(plato.imagen!, width: 180, height: 180, fit: BoxFit.cover),
              )
            else
              const Icon(Icons.image, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text("Detalle del plato: ${plato.nombre}"),
            const SizedBox(height: 8),
            const Text("Aquí podrás editar imagen, descripción y precio."),
          ],
        ),
      ),
    );
  }
}
