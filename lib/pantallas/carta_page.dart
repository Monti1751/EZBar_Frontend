import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:log_in/models/plato.dart';
import 'package:log_in/models/categoria.dart';
import '../providers/visual_settings_provider.dart';
import 'settings_menu.dart';
import '../services/hybrid_data_service.dart';
import '../services/local_storage_service.dart';
import '../l10n/app_localizations.dart';
import '../config/app_constants.dart';

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(
    String hint, IconData icon, bool darkMode) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: darkMode ? Colors.grey[400] : Colors.grey[600]),
    prefixIcon:
        Icon(icon, color: darkMode ? Colors.white70 : AppConstants.darkBrown),
    filled: true,
    fillColor: darkMode ? Colors.grey[800] : Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      borderSide: BorderSide(
          color: darkMode ? Colors.white70 : AppConstants.darkBrown,
          width: AppConstants.borderWidthThin),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      borderSide: BorderSide(
          color: darkMode ? Colors.greenAccent : AppConstants.primaryGreen,
          width: AppConstants.borderWidthThick),
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
  final TextEditingController _searchController = TextEditingController();
  final HybridDataService _dataService = HybridDataService();

  List<Seccion> secciones = [];
  final LocalStorageService _localStorage = LocalStorageService();
  String _searchQuery = "";

  // Variables de diagnóstico
  int _apiCatsCount = 0;
  int _apiProdsCount = 0;
  List<dynamic> _lastRawProds = [];
  String _diagError = "";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final cats = await _dataService.obtenerCategorias();
      final prods = await _dataService.obtenerProductos();

      setState(() {
        _apiCatsCount = cats.length;
        _apiProdsCount = prods.length;
        _lastRawProds = prods;
      });

      debugPrint(
          "📡 API: ${cats.length} categorías y ${prods.length} productos recibidos.");

      setState(() {
        _diagError =
            prods.isEmpty ? "Lista de productos vacía (Fallback??)" : "";
      });
      if (prods.isNotEmpty) {
        debugPrint("🔍 Ejemplo primer producto: ${prods.first}");
      }

      // Obtener lista negra de categorías eliminadas
      final deletedCategoryIds = await _localStorage.getDeletedCategories();

      List<Seccion> loaded = [];
      for (var c in cats) {
        final categoria = Categoria.fromJson(c as Map<String, dynamic>);

        // Filtrar categorías eliminadas
        if (deletedCategoryIds.contains(categoria.id)) {
          continue;
        }

        Seccion s = Seccion(id: categoria.id, nombre: categoria.nombre);
        var pList = prods.where((p) {
          int? pCatId;

          try {
            if (p is Plato) {
              pCatId = p.categoriaId;
            } else if (p is Map) {
              // Buscar en todas las combinaciones posibles de llaves
              final rawCatId = p['categoria_id'] ??
                  p['categoriaId'] ??
                  (p['categoria'] != null
                      ? (p['categoria']['categoria_id'] ?? p['categoria']['id'])
                      : null);

              if (rawCatId is int)
                pCatId = rawCatId;
              else if (rawCatId is String) pCatId = int.tryParse(rawCatId);
            }
          } catch (e) {
            debugPrint("Error al emparejar producto: $e");
          }

          bool matches = (pCatId != null &&
              categoria.id != null &&
              pCatId.toString() == categoria.id.toString());
          return matches;
        }).toList();

        debugPrint(
            "Match para ${categoria.nombre} (ID: ${categoria.id}): ${pList.length} platos.");

        for (var p in pList) {
          try {
            if (p is Plato) {
              s.platos.add(p);
            } else {
              final map = Map<String, dynamic>.from(p as Map);
              s.platos.add(Plato.fromMap(map));
            }
          } catch (e) {
            debugPrint("Error al procesar plato: $e");
          }
        }
        debugPrint(
            "Sección '${categoria.nombre}' cargada con ${s.platos.length} platos.");
        loaded.add(s);
      }
      debugPrint("Total de secciones cargadas: ${loaded.length}");
      setState(() {
        secciones = loaded;
      });

      // Guardar en localStorage para uso offline
      await _localStorage.saveSecciones(loaded);
    } catch (e) {
      debugPrint("❌ Error al cargar datos de carta: $e");
      if (mounted) {
        setState(() {
          _diagError = "ERROR: $e";
        });
      }

      // Intenta cargar del almacenamiento local
      try {
        final seccionesRawData = await _localStorage.getSecciones();

        List<Seccion> seccionesLocal = [];
        for (var data in seccionesRawData) {
          Seccion s = Seccion(
            id: data['id'],
            nombre: data['nombre'],
          );
          s.isOpen = data['isOpen'] ?? false;

          if (data['platos'] != null && data['platos'] is List) {
            for (var p in data['platos']) {
              s.platos.add(
                Plato(
                  id: p['id'],
                  nombre: p['nombre'],
                  precio: (p['precio'] as num).toDouble(),
                  imagenUrl: p['imagenUrl'],
                  imagenBlob: p['imagenBlob'],
                ),
              );
            }
          }
          seccionesLocal.add(s);
        }

        setState(() {
          secciones = seccionesLocal;
        });
      } catch (e2) {
        print('❌ Error cargando desde localStorage: $e2');
        setState(() {
          secciones = [];
        });
      }
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(
      context,
      listen: false,
    );
    return BoxDecoration(
      color: settings.darkMode ? const Color(0xFF2C2C2C) : Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmallMedium),
      border: Border.all(color: Colors.black26),
    );
  }

  @override
  void dispose() {
    _seccionController.dispose();
    _platoController.dispose();
    _searchController.dispose();
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
        duration: AppConstants.snackBarMedium,
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

    final Color fondo = settings.darkMode
        ? const Color(0xFF1E1E1E)
        : AppConstants.backgroundCream;
    final Color barraSuperior =
        settings.colorBlindMode ? Colors.blue : AppConstants.primaryGreen;
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;
    final double fontSize = settings.currentFontSize;

    List<Seccion> seccionesMostrar = secciones;
    if (_searchQuery.isNotEmpty) {
      seccionesMostrar = secciones.where((seccion) {
        final queryLower = _searchQuery.toLowerCase();
        final matchesSeccion =
            seccion.nombre.toLowerCase().contains(queryLower);
        final matchesPlato = seccion.platos
            .any((p) => p.nombre.toLowerCase().contains(queryLower));
        return matchesSeccion || matchesPlato;
      }).toList();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          // Barra superior
          Container(
            height: AppConstants.appBarHeight,
            color: barraSuperior,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: textoGeneral, size: AppConstants.defaultIconSize),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: Icon(Icons.menu,
                      color: textoGeneral, size: AppConstants.defaultIconSize),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: loginInputDecoration(
                  AppLocalizations.of(context).translate('search_hint'),
                  Icons.search,
                  settings.darkMode),
              style: TextStyle(color: textoGeneral, fontSize: fontSize),
            ),
          ),

          // Lista de secciones
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: _searchQuery.isEmpty,
              itemCount: seccionesMostrar.length,
              onReorder: (oldIndex, newIndex) {
                if (_searchQuery.isNotEmpty) return;
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = secciones.removeAt(oldIndex);
                  secciones.insert(newIndex, item);
                });
                _localStorage.saveSecciones(secciones);
              },
              itemBuilder: (context, index) {
                final seccion = seccionesMostrar[index];

                List<Plato> platosMostrar = seccion.platos;
                if (_searchQuery.isNotEmpty) {
                  final queryLower = _searchQuery.toLowerCase();
                  final matchesSeccion =
                      seccion.nombre.toLowerCase().contains(queryLower);
                  if (!matchesSeccion) {
                    platosMostrar = seccion.platos
                        .where(
                            (p) => p.nombre.toLowerCase().contains(queryLower))
                        .toList();
                  }
                }

                return Container(
                  key: ValueKey('seccion_${seccion.id ?? seccion.nombre}'),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: barraSuperior,
                    borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSmallMedium),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                seccion.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  color: textoGeneral,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.black,
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
                                                .then((success) {
                                              if (success) {
                                                _localStorage
                                                    .addDeletedCategory(
                                                  seccion.id!,
                                                );
                                                setState(() {
                                                  secciones.remove(seccion);
                                                });
                                                Navigator.of(popContext).pop();
                                              } else {
                                                // Manejo genérico de fallo
                                                Navigator.of(popContext).pop();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "No se pudo eliminar la sección."),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }).catchError((e) {
                                              Navigator.of(popContext).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "Ocurrió un error al eliminar la sección. Inténtelo de nuevo.")),
                                              );
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
                      if (seccion.isOpen || _searchQuery.isNotEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: Container(
                            margin: const EdgeInsets.all(
                                AppConstants.paddingMedium),
                            decoration: _cardDecoration(context),
                            padding: const EdgeInsets.all(
                                AppConstants.paddingMedium),
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
                                          settings.darkMode,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppConstants.paddingSmall),
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
                                                  'descripcion':
                                                      '', // sin descripción por ahora
                                                  'precio': nuevoPlato.precio,
                                                  'categoria_id': seccion.id,
                                                  // 'ingredientes': nuevoPlato.ingredientes,
                                                  // 'extras': nuevoPlato.extras,
                                                  // 'alergenos': nuevoPlato.alergenos,
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
                                  child: ReorderableListView.builder(
                                    buildDefaultDragHandles:
                                        _searchQuery.isEmpty,
                                    itemCount: platosMostrar.length,
                                    onReorder: (oldIndex, newIndex) {
                                      if (_searchQuery.isNotEmpty) return;
                                      setState(() {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final item =
                                            seccion.platos.removeAt(oldIndex);
                                        seccion.platos.insert(newIndex, item);
                                      });
                                      _localStorage.saveSecciones(secciones);
                                    },
                                    itemBuilder: (context, platoIndex) {
                                      final plato = platosMostrar[platoIndex];
                                      return Container(
                                        key: ValueKey(
                                            'plato_${plato.id ?? plato.nombre}_${plato.hashCode}'),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: AppConstants.paddingXXSmall,
                                          horizontal:
                                              AppConstants.paddingXXSmall,
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
                                                      'categoria_id':
                                                          seccion.id,
                                                      // 'ingredientes': platoEditado.ingredientes,
                                                      // 'extras': platoEditado.extras,
                                                      // 'alergenos': platoEditado.alergenos,
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
                                                AppConstants.paddingLarge),
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
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .borderRadiusSmall),
                                                        child: SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child:
                                                              _buildListImage(
                                                                  plato),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: AppConstants
                                                              .paddingMedium),
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
                                                    if (widget.onAddToCuenta !=
                                                        null)
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
                                                        color: Colors.black,
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
                  vertical: AppConstants.buttonPaddingVertical,
                  horizontal: AppConstants.paddingXXLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
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
                        settings.darkMode,
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
                                final cat = Categoria.fromJson(nueva);
                                secciones.add(
                                  Seccion(
                                    id: cat.id,
                                    nombre: cat.nombre,
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
