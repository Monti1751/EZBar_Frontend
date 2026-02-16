import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:log_in/models/plato.dart';
import '../providers/visual_settings_provider.dart';
import 'settings_menu.dart';
import '../services/hybrid_data_service.dart';
import '../services/local_storage_service.dart';
import '../l10n/app_localizations.dart';

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF4A4025)),
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4A4025), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7BA238), width: 2.2),
    ),
  );
}

/// Modelo de Sección
class Seccion {
  int? id;
  String nombre;
  bool isOpen = false;
  List<Plato> platos = [];
  Seccion({this.id, required this.nombre});
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
  final HybridDataService _dataService = HybridDataService();

  List<Seccion> secciones = [];
  final LocalStorageService _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final cats = await _dataService.obtenerCategorias();
      final prods = await _dataService.obtenerProductos();

      // Obtener lista negra de categorías eliminadas
      final deletedCategoryIds = await _localStorage.getDeletedCategories();

      List<Seccion> loaded = [];
      for (var c in cats) {
        // Filtrar categorías eliminadas
        if (deletedCategoryIds.contains(c['categoria_id'])) {
          continue;
        }

        Seccion s = Seccion(id: c['categoria_id'], nombre: c['nombre']);
        var pList = prods.where((p) {
          if (p['categoria'] != null && p['categoria'] is Map) {
            return p['categoria']['categoria_id'] == c['categoria_id'];
          }
          // Fallback
          return false;
        });

        for (var p in pList) {
          // Convertir precio (puede ser String o num)
          final precioRaw = p['precio'];
          final precio = precioRaw is String
              ? (double.tryParse(precioRaw) ?? 0.0)
              : (precioRaw as num).toDouble();

          s.platos.add(
            Plato(
              id: p['producto_id'],
              nombre: p['nombre'],
              precio: precio,
              imagenUrl: p['imagenUrl'],
              imagenBlob: p['imagenBlob'],
            ),
          );
        }
        loaded.add(s);
      }
      setState(() {
        secciones = loaded;
      });
    } catch (e) {
      // print("Error loading data: $e");
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(
      context,
      listen: false,
    );
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
        content: Text(
            "${AppLocalizations.of(context).translate('added_to_bill')}${plato.nombre}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildListImage(Plato plato) {
    if (plato.imagen != null) {
      if (kIsWeb) {
        return Image.network(plato.imagen!.path, fit: BoxFit.cover);
      }
      return Image.file(File(plato.imagen!.path), fit: BoxFit.cover);
    } else if (plato.imagenBlob != null && plato.imagenBlob!.isNotEmpty) {
      try {
        String cleanBase64 = plato.imagenBlob!;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } catch (e) {
        return const Icon(Icons.error);
      }
    } else if (plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty) {
      return Image.network(
        plato.imagenUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.black26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color fondo =
        settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior =
        settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: textoGeneral, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
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
              decoration: loginInputDecoration(
                  AppLocalizations.of(context).translate('search_hint'),
                  Icons.search),
              style: TextStyle(color: textoGeneral, fontSize: fontSize),
            ),
          ),

          // Lista de secciones
          Expanded(
            child: ListView.builder(
              itemCount: secciones.length,
              itemBuilder: (context, index) {
                final seccion = secciones[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: "Eliminar sección",
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      "Confirmar eliminación",
                                    ),
                                    content: Text(
                                      "¿Seguro que quieres eliminar la sección '${seccion.nombre}'?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text(AppLocalizations.of(context)
                                            .translate('cancel')),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final popContext = ctx;
                                          if (seccion.id != null) {
                                            _dataService
                                                .eliminarCategoria(
                                              seccion.id!,
                                            )
                                                .then((_) {
                                              _localStorage.addDeletedCategory(
                                                seccion.id!,
                                              );
                                            }).then((_) {
                                              setState(() {
                                                secciones.remove(seccion);
                                              });
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(popContext).pop();
                                            }).catchError((e) {
                                              // print('Error: $e');
                                            });
                                          } else {
                                            setState(() {
                                              secciones.remove(seccion);
                                            });
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(popContext).pop();
                                          }
                                        },
                                        child: const Text(
                                          "Eliminar",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Icon(
                              seccion.isOpen
                                  ? Icons.expand_less
                                  : Icons.expand_more,
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
                                // Añadir plato (solo nombre) -> abre editor y añade al volver
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _platoController,
                                        decoration: loginInputDecoration(
                                          "Nombre del plato",
                                          Icons.fastfood,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                      tooltip: "Crear plato",
                                      onPressed: () async {
                                        final nombre =
                                            _platoController.text.trim();
                                        if (nombre.isNotEmpty) {
                                          final nuevoPlato =
                                              await Navigator.push<Plato>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => PlatoEditorPage(
                                                plato: Plato(
                                                  nombre: nombre,
                                                  precio: 0.0,
                                                ),
                                              ),
                                            ),
                                          );

                                          if (nuevoPlato != null) {
                                            if (seccion.id != null) {
                                              try {
                                                final data = {
                                                  'nombre': nuevoPlato.nombre,
                                                  'precio': nuevoPlato.precio,
                                                  'categoria': {
                                                    'categoria_id': seccion.id,
                                                  },
                                                  'ingredientes':
                                                      nuevoPlato.ingredientes,
                                                  'extras': nuevoPlato.extras,
                                                  'alergenos':
                                                      nuevoPlato.alergenos,
                                                  'imagenUrl':
                                                      nuevoPlato.imagenUrl,
                                                  'imagenBlob':
                                                      nuevoPlato.imagenBlob,
                                                };
                                                final res = await _dataService
                                                    .crearProducto(data);
                                                nuevoPlato.id =
                                                    res['producto_id'];
                                                setState(() {
                                                  seccion.platos.add(
                                                    nuevoPlato,
                                                  );
                                                });
                                              } catch (e) {
                                                // print(
                                                //   "Error creating product: $e",
                                                // );
                                              }
                                            }
                                            _platoController.clear();
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Lista de platos
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: seccion.platos.length,
                                    itemBuilder: (context, platoIndex) {
                                      final plato = seccion.platos[platoIndex];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 4,
                                        ),
                                        decoration: _cardDecoration(
                                          context,
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            await Navigator.push<Plato>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    PlatoEditorPage(
                                                  plato: plato,
                                                  onSave: (platoEditado) async {
                                                    final data = {
                                                      'nombre':
                                                          platoEditado.nombre,
                                                      'precio':
                                                          platoEditado.precio,
                                                      'categoria': {
                                                        'categoria_id':
                                                            seccion.id,
                                                      },
                                                      'ingredientes':
                                                          platoEditado
                                                              .ingredientes,
                                                      'extras':
                                                          platoEditado.extras,
                                                      'alergenos': platoEditado
                                                          .alergenos,
                                                      'imagenUrl': platoEditado
                                                          .imagenUrl,
                                                      'imagenBlob': platoEditado
                                                          .imagenBlob,
                                                    };
                                                    await _dataService
                                                        .actualizarProducto(
                                                            platoEditado.id!,
                                                            data);
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            );
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Imagen pequeña + nombre
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child:
                                                              _buildListImage(
                                                                  plato),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          plato.nombre,
                                                          style: TextStyle(
                                                            fontSize: fontSize,
                                                            color: textoGeneral,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Acciones: añadir a cuenta (+) y eliminar
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.add_circle,
                                                        color: barraSuperior,
                                                      ),
                                                      tooltip:
                                                          "Añadir a la cuenta",
                                                      onPressed: () =>
                                                          _addPlatoToCuenta(
                                                        plato,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      tooltip: "Eliminar plato",
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              AlertDialog(
                                                            title: const Text(
                                                              "Confirmar eliminación",
                                                            ),
                                                            content: Text(
                                                              "¿Seguro que quieres eliminar el plato '${plato.nombre}'?",
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator
                                                                        .of(
                                                                  ctx,
                                                                ).pop(),
                                                                child:
                                                                    const Text(
                                                                  "Cancelar",
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  final popContext =
                                                                      ctx;
                                                                  if (plato
                                                                          .id !=
                                                                      null) {
                                                                    _dataService
                                                                        .eliminarProducto(
                                                                      plato.id!,
                                                                    )
                                                                        .then(
                                                                            (_) {
                                                                      setState(
                                                                          () {
                                                                        seccion
                                                                            .platos
                                                                            .remove(plato);
                                                                      });
                                                                      // ignore: use_build_context_synchronously
                                                                      Navigator.of(
                                                                              popContext)
                                                                          .pop();
                                                                    }).catchError(
                                                                      (e) {
                                                                        // Error
                                                                      },
                                                                    );
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      seccion
                                                                          .platos
                                                                          .remove(
                                                                              plato);
                                                                    });
                                                                    Navigator.of(
                                                                            popContext)
                                                                        .pop();
                                                                  }
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Eliminar",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
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
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón para agregar sección
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: barraSuperior,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).translate('add_section'),
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
              onPressed: () {
                _seccionController.clear();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                        AppLocalizations.of(context).translate('new_section')),
                    content: TextField(
                      controller: _seccionController,
                      decoration: loginInputDecoration(
                        AppLocalizations.of(context)
                            .translate('section_name_hint'),
                        Icons.list,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                            AppLocalizations.of(context).translate('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          final popContext = ctx;
                          if (_seccionController.text.isNotEmpty) {
                            _dataService
                                .crearCategoria(
                              _seccionController.text,
                            )
                                .then((nueva) {
                              setState(() {
                                secciones.add(
                                  Seccion(
                                    id: nueva['categoria_id'],
                                    nombre: nueva['nombre'],
                                  ),
                                );
                              });
                              // ignore: use_build_context_synchronously
                              Navigator.pop(popContext);
                            }).catchError((e) {
                              // print("Error creating category: $e");
                              // ignore: use_build_context_synchronously
                              Navigator.pop(popContext);
                            });
                          } else {
                            Navigator.pop(popContext);
                          }
                        },
                        child:
                            Text(AppLocalizations.of(context).translate('add')),
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
