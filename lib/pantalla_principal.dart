import 'package:flutter/material.dart';
import 'settings_menu.dart';
import 'package:provider/provider.dart';
import 'cuenta.dart';
import 'visual_settings_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'models/mesa.dart';
import 'models/zona.dart';

InputDecoration loginInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Color(0xFF4A4025)),
    filled: true,
    fillColor: Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4A4025), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF7BA238), width: 2.2),
    ),
  );
}

/// Pantalla principal que solo devuelve el menú principal
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainMenu();
  }
}

/// === WIDGET ZONA CON API===
class ZoneWidget extends StatefulWidget {
  final Zone zone;
  final VoidCallback onDelete;
  final Function(Zone) onUpdate;

  const ZoneWidget({
    super.key,
    required this.zone,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  final TextEditingController _tableController = TextEditingController();
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();
  int _tableCounter = 1;

  @override
  void initState() {
    super.initState();
    if (widget.zone.name.isNotEmpty) {
      _cargarMesasDeZona();
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  /// ✅ Cargar mesas de la zona desde el backend (corregido)
  Future<void> _cargarMesasDeZona() async {
    // ✅ IMPORTANTE: Limpiar la lista de mesas al inicio para evitar mezclas entre zonas
    if (mounted) {
      setState(() {
        widget.zone.tables.clear();
      });
    }

    // 1. Cargar localmente primero
    final mesasLocales = await _localStorage.getTables(widget.zone.name);
    if (mounted && mesasLocales.isNotEmpty) {
      setState(() {
        // ✅ Crear una NUEVA lista en lugar de asignar directamente
        // ✅ Filtrar defensivamente por ubicacion para asegurar aislamiento
        widget.zone.tables = mesasLocales
            .where((mesa) => mesa.ubicacion == widget.zone.name)
            .toList();
        // Actualizar contador para evitar duplicados si es posible
        if (widget.zone.tables.isNotEmpty) {
          _tableCounter = widget.zone.tables.length + 1;
        }
      });
    }

    try {
      final mesas = await _apiService.obtenerMesasPorZona(widget.zone.name);
      if (mounted) {
        setState(() {
          // ✅ Crear una NUEVA lista y filtrar defensivamente
          final mesasFiltradas = mesas
              .map((m) => Mesa.fromJson(m))
              .where((mesa) => mesa.ubicacion == widget.zone.name)
              .toList();
          widget.zone.tables = mesasFiltradas;
          if (widget.zone.tables.isNotEmpty) {
            _tableCounter = widget.zone.tables.length + 1;
          }
        });
        // 2. Guardar en local después de obtener del API
        await _localStorage.saveTables(widget.zone.name, widget.zone.tables);
      }
    } catch (e) {
      if (mounted) {
        // Si falla la API y no teníamos datos locales (o queremos notificar error igual)
        // Pero si ya mostramos datos locales, la UX es mejor.
        if (widget.zone.tables.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al cargar mesas: $e')));
        }
      }
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

  Widget _buildAddTableField(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _tableController,
              decoration: loginInputDecoration(
                "Nombre de la mesa",
                Icons.table_restaurant_outlined,
              ),
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.add,
              color: settings.colorBlindMode
                  ? Colors.blue
                  : const Color(0xFF7BA238),
            ),
            onPressed: () async {
              if (_tableController.text.isNotEmpty) {
                final nuevaMesa = Mesa(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _tableController.text,
                  ubicacion: widget.zone.name,
                  numeroMesa: _tableCounter++,
                  capacidad: 4,
                );

                try {
                  // Primero agregar a la lista local
                  setState(() {
                    widget.zone.tables.add(nuevaMesa);
                    _tableController.clear();
                  });

                  // Luego guardar TODAS las mesas de la zona en el backend
                  final mesasJson = widget.zone.tables
                      .map((mesa) => mesa.toJson())
                      .toList();
                  await _apiService.guardarMesasDeZona(
                    widget.zone.name,
                    mesasJson,
                  );

                  // Guardar localmente también
                  await _localStorage.saveTables(
                    widget.zone.name,
                    widget.zone.tables,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mesa "${nuevaMesa.name}" guardada'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar mesa: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final double fontSize = settings.currentFontSize;
    final Color tarjetaZona = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final Color textoZona = settings.darkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tarjetaZona,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.zone.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: textoZona,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Eliminar zona',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirmar eliminación"),
                        content: Text(
                          "¿Seguro que quieres eliminar la zona '${widget.zone.name}'?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await _apiService.eliminarZona(
                                  widget.zone.name,
                                );
                                widget.onDelete();
                                Navigator.of(ctx).pop();
                              } catch (e) {
                                Navigator.of(ctx).pop();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al eliminar zona: $e',
                                      ),
                                    ),
                                  );
                                }
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
                  widget.zone.isOpen ? Icons.expand_less : Icons.expand_more,
                  color: textoZona,
                ),
              ],
            ),
            onTap: () {
              setState(() => widget.zone.isOpen = !widget.zone.isOpen);
            },
          ),

          if (widget.zone.isOpen)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: _cardDecoration(context),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _buildAddTableField(context),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var table in widget.zone.tables)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CuentaMesaPage(nombreMesa: table.name),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: _cardDecoration(context),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          table.getEstadoBadge(context),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              table.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: settings.darkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: fontSize,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: settings.darkMode
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              switch (value) {
                                                case 'libre':
                                                  table.setEstado(1);
                                                  break;
                                                case 'reservado':
                                                  table.setEstado(2);
                                                  break;
                                                case 'ocupado':
                                                  table.setEstado(3);
                                                  break;
                                              }
                                            });
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'libre',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Libre'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'reservado',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.orange,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Reservado'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'ocupado',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Ocupado'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                  "Confirmar eliminación",
                                                ),
                                                content: Text(
                                                  "¿Seguro que quieres eliminar la mesa '${table.name}'?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(),
                                                    child: const Text(
                                                      "Cancelar",
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      try {
                                                        // Primero eliminar localmente
                                                        setState(() {
                                                          widget.zone.tables
                                                              .remove(table);
                                                        });

                                                        // Luego guardar el estado actualizado en el backend
                                                        final mesasJson = widget
                                                            .zone
                                                            .tables
                                                            .map(
                                                              (mesa) =>
                                                                  mesa.toJson(),
                                                            )
                                                            .toList();
                                                        await _apiService
                                                            .guardarMesasDeZona(
                                                              widget.zone.name,
                                                              mesasJson,
                                                            );

                                                        // Actualizar local storage
                                                        await _localStorage
                                                            .saveTables(
                                                              widget.zone.name,
                                                              widget
                                                                  .zone
                                                                  .tables,
                                                            );

                                                        Navigator.of(ctx).pop();

                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Mesa "${table.name}" eliminada',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        Navigator.of(ctx).pop();
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Error al eliminar mesa: $e',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: const Text(
                                                      "Eliminar",
                                                      style: TextStyle(
                                                        color: Colors.red,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Color principal del tema
const Color mainColor = Color(0xFF7BA238);

/// Menú principal con API
class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  bool _showAddZoneField = false;
  final TextEditingController _zoneController = TextEditingController();
  List<Zone> zones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarZonas();
  }

  /// ✅ Cargar zonas desde el backend (corregido)
  Future<void> _cargarZonas() async {
    // 1. Cargar localmente primero
    final zonasLocales = await _localStorage.getZones();
    if (mounted && zonasLocales.isNotEmpty) {
      setState(() {
        // ✅ Asegurar que cada zona tenga una lista de mesas vacía y fresca
        zones = zonasLocales.map((z) {
          z.tables = []; // Limpiar tablas para evitar referencias compartidas
          return z;
        }).toList();
        _isLoading = false;
      });
    }

    setState(() {
      if (zones.isEmpty)
        _isLoading = true; // Solo mostrar loading si no hay datos locales
      _error = null;
    });

    try {
      final zonasData = await _apiService.obtenerZonas();
      setState(() {
        // ✅ Crear zonas frescas con listas de mesas vacías
        zones = zonasData.map((z) {
          final zona = Zone.fromJson(z);
          zona.tables = []; // Inicializar con lista vacía
          return zona;
        }).toList();
        _isLoading = false;
      });
      // 2. Guardar en local
      await _localStorage.saveZones(zones);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Crear zona en el backend
  Future<void> _crearZona(String nombre) async {
    try {
      final nuevaZona = Zone(name: nombre);
      final response = await _apiService.crearZona(nuevaZona.toJson());
      final zonaCreada = Zone.fromJson(response);

      setState(() {
        zones.add(zonaCreada);
        _zoneController.clear();
        _showAddZoneField = false;
      });

      // Guardar en local
      await _localStorage.saveZones(zones);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zona creada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear zona: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final Color fondo = settings.darkMode
        ? Colors.black
        : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final double fontSize = settings.currentFontSize;
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          Container(
            height: 55,
            color: barraSuperior,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: textoGeneral, size: 28),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAddZoneField = !_showAddZoneField;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: barraSuperior,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: Text(
                        "Agregar Zona",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textoGeneral,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (_showAddZoneField)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _zoneController,
                            decoration: loginInputDecoration(
                              "Nombre de la zona",
                              Icons.map_outlined,
                            ),
                            style: TextStyle(color: textoGeneral),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.check, color: barraSuperior),
                          onPressed: () {
                            if (_zoneController.text.isNotEmpty) {
                              _crearZona(_zoneController.text);
                            }
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: barraSuperior,
                            ),
                          )
                        : _error != null
                        ? Center(
                            child: Text(
                              'Error: $_error',
                              style: TextStyle(color: textoGeneral),
                            ),
                          )
                        : ListView(
                            children: zones
                                .map(
                                  (z) => ZoneWidget(
                                    zone: z,
                                    onDelete: () async {
                                      setState(() {
                                        zones.remove(z);
                                      });
                                      // Eliminar de local storage también
                                      await _localStorage.saveZones(zones);
                                      await _localStorage.removeTables(z.name);
                                    },
                                    onUpdate: (updatedZone) {
                                      setState(() {
                                        final index = zones.indexWhere(
                                          (zone) => zone.id == updatedZone.id,
                                        );
                                        if (index != -1) {
                                          zones[index] = updatedZone;
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
