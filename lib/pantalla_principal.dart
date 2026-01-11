import 'package:flutter/material.dart';
import 'package:log_in/settings_menu.dart';
import 'package:provider/provider.dart';
import 'package:log_in/cuenta.dart';
import 'visual_settings_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'models/zona.dart' as models;
import 'models/mesa.dart' as models;

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

/// === MODELO DE ZONA ===
class Zone {
  String? id;
  String name;
  bool isOpen = false;
  List<Mesa> tables = [];

  Zone({this.id, required this.name});

  // ✅ Convertir desde JSON del backend (adaptado para el nuevo formato)
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['nombre']?.toString(), // Usa 'nombre' como ID
      name: json['nombre'] ?? json['name'] ?? '',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {'nombre': name};
  }
}

/// === MODELO DE MESA ===
class Mesa {
  int? id;
  String name;
  String estado; // "libre", "reservado", "ocupado"
  String ubicacion;
  int numeroMesa;
  int capacidad;

  Mesa({
    this.id,
    required this.name,
    required this.ubicacion,
    required this.numeroMesa,
    required this.capacidad,
    this.estado = "libre",
  });

  // Convertir desde JSON del backend
  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: int.tryParse(
        json['mesa_id']?.toString() ?? json['id']?.toString() ?? '',
      ),
      name:
          json['nombre'] ?? json['name'] ?? 'Mesa ${json['numero_mesa'] ?? ''}',
      ubicacion: json['ubicacion'] ?? '',
      numeroMesa:
          json['numero_mesa'] ?? json['numeroMesa'] ?? json['numero'] ?? 0,
      capacidad: json['capacidad'] ?? 4,
      estado: json['estado'] ?? 'libre',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': name,
      'ubicacion': ubicacion,
      'numero_mesa': numeroMesa,
      'capacidad': capacidad,
      'estado': estado,
    };
  }

  void setEstado(int disposicion) {
    switch (disposicion) {
      case 1:
        estado = "libre";
        break;
      case 2:
        estado = "reservada";
        break;
      case 3:
        estado = "ocupada";
        break;
      default:
        estado = "libre";
    }
  }

  Color getColorByEstado(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(
      context,
      listen: false,
    );
    if (settings.colorBlindMode) {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.blue;
        case 'reservada':
          return Colors.orange;
        case 'ocupada':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    } else {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.green;
        case 'reservada':
          return Colors.orange;
        case 'ocupada':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }

  /// Badge discreto: solo borde y texto con el color del estado
  Widget getEstadoBadge(BuildContext context) {
    final Color color = getColorByEstado(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ).copyWith(color: color),
      ),
    );
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
    try {
      final mesas = await _apiService.obtenerMesasPorZona(widget.zone.name);
      
      // Obtener lista negra de mesas eliminadas
      final deletedIds = await _localStorage.getDeletedTables();
      
      if (mounted) {
        setState(() {
          // Filtrar mesas eliminadas
          widget.zone.tables = mesas
              .where((m) => !deletedIds.contains(m['mesa_id']))
              .map((m) => Mesa.fromJson(m))
              .toList();
        });
        // Guardar en almacenamiento local después de cargar del backend
        await _guardarMesasLocalmente();
      }
    } catch (e) {
      print('Error cargando mesas del backend: $e');
      // Si falla el backend, intentar cargar desde almacenamiento local
      await _cargarMesasLocalmente();
    }
  }

  /// Guardar mesas en almacenamiento local
  Future<void> _guardarMesasLocalmente() async {
    try {
      // Convertir Mesa a models.Mesa (modelo compatible con LocalStorageService)
      final mesasParaGuardar = widget.zone.tables.map((m) {
        return models.Mesa(
          id: m.id?.toString() ?? '',
          name: m.name,
          ubicacion: widget.zone.name,
          numeroMesa: m.numeroMesa,
          capacidad: m.capacidad,
          estado: m.estado,
        );
      }).toList();
      await _localStorage.saveTables(widget.zone.name, mesasParaGuardar);
    } catch (e) {
      print('Error guardando mesas localmente: $e');
    }
  }

  /// Cargar mesas desde almacenamiento local
  Future<void> _cargarMesasLocalmente() async {
    try {
      final mesasLocales = await _localStorage.getTables(widget.zone.name);
      if (mesasLocales.isNotEmpty && mounted) {
        setState(() {
          widget.zone.tables = mesasLocales.map((m) {
            return Mesa(
              id: int.tryParse(m.id),
              name: m.name,
              ubicacion: m.ubicacion,
              numeroMesa: m.numeroMesa,
              capacidad: m.capacidad,
              estado: m.estado,
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error cargando mesas localmente: $e');
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
                  id: null, // No asignar ID local, esperar respuesta del backend
                  name: _tableController.text,
                  ubicacion: widget.zone.name,
                  numeroMesa: _tableCounter++,
                  capacidad: 4,
                );

                // Intentar crear en el backend
                try {
                  final mesaData = nuevaMesa.toJson();
                  final response = await _apiService.crearMesa(mesaData);
                  
                  // Actualizar con el ID del backend
                  if (response['mesa_id'] != null) {
                    nuevaMesa.id = response['mesa_id'];
                  }
                  
                  print('✅ Mesa creada en backend con ID: ${nuevaMesa.id}');
                } catch (e) {
                  print('⚠️ Error creando mesa en backend: $e');
                  // Asignar ID temporal si falla el backend
                  nuevaMesa.id = DateTime.now().millisecondsSinceEpoch;
                }

                // Añadir a la lista local
                setState(() {
                  widget.zone.tables.add(nuevaMesa);
                  _tableController.clear();
                });

                // Guardar en almacenamiento local
                await _guardarMesasLocalmente();
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
                            onPressed: () {
                              widget.onDelete();
                              Navigator.of(ctx).pop();
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
                                        CuentaMesaPage(
                                          nombreMesa: table.name,
                                          nombreZona: widget.zone.name,
                                        ),
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
                                          onSelected: (value) async {
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
                                            // Guardar cambios de estado
                                            await _guardarMesasLocalmente();
                                            
                                            // Intentar actualizar en backend
                                            try {
                                              if (table.id != null) {
                                                await _apiService.actualizarMesa(
                                                  table.id!,
                                                  {'estado': table.estado},
                                                );
                                              }
                                            } catch (e) {
                                              print('Error actualizando mesa en backend: $e');
                                            }
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
                                                      // Intentar eliminar del backend
                                                      try {
                                                        if (table.id != null) {
                                                          await _apiService.eliminarMesa(table.id!);
                                                        }
                                                      } catch (e) {
                                                        print('Error eliminando mesa del backend: $e');
                                                      }
                                                      
                                                      // Añadir a lista negra local
                                                      if (table.id != null) {
                                                        await _localStorage.addDeletedTable(table.id!);
                                                      }
                                                      
                                                      // Eliminar de la lista local
                                                      setState(() {
                                                        widget.zone.tables
                                                            .remove(table);
                                                      });
                                                      
                                                      // Guardar cambios localmente
                                                      await _guardarMesasLocalmente();
                                                      
                                                      Navigator.of(ctx).pop();
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final zonasData = await _apiService.obtenerZonas();
      setState(() {
        zones = zonasData.map((z) => Zone.fromJson(z)).toList();
        _isLoading = false;
      });
      // Guardar en almacenamiento local después de cargar del backend
      await _guardarZonasLocalmente();
    } catch (e) {
      print('Error cargando zonas del backend: $e');
      // Si falla el backend, intentar cargar desde almacenamiento local
      await _cargarZonasLocalmente();
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Guardar zonas en almacenamiento local
  Future<void> _guardarZonasLocalmente() async {
    try {
      // Convertir Zone a Zona (modelo compatible con LocalStorageService)
      final zonasParaGuardar = zones.map((z) {
        return models.Zona(
          nombre: z.name,
          totalMesas: 0,
          mesasLibres: 0,
          mesasOcupadas: 0,
        );
      }).toList();
      await _localStorage.saveZones(zonasParaGuardar);
    } catch (e) {
      print('Error guardando zonas localmente: $e');
    }
  }

  /// Cargar zonas desde almacenamiento local
  Future<void> _cargarZonasLocalmente() async {
    try {
      final zonasLocales = await _localStorage.getZones();
      if (zonasLocales.isNotEmpty) {
        setState(() {
          zones = zonasLocales.map((z) {
            return Zone(id: z.nombre, name: z.nombre);
          }).toList();
        });
      }
    } catch (e) {
      print('Error cargando zonas localmente: $e');
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

      // Guardar en almacenamiento local
      await _guardarZonasLocalmente();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zona creada correctamente')),
        );
      }
    } catch (e) {
      // Si falla el backend, intentar guardar solo localmente
      final nuevaZona = Zone(id: nombre, name: nombre);
      setState(() {
        zones.add(nuevaZona);
        _zoneController.clear();
        _showAddZoneField = false;
      });
      await _guardarZonasLocalmente();
      
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Zona guardada localmente (backend no disponible)')));
      }
    }
  }

  /// Eliminar zona
  Future<void> _eliminarZona(Zone zona) async {
    try {
      if (zona.id != null) {
        await _apiService.eliminarZona(zona.id!);
      }
    } catch (e) {
      print('Error eliminando zona del backend: $e');
    }
    
    // Eliminar de la lista local
    setState(() {
      zones.remove(zona);
    });
    
    // Guardar cambios localmente
    await _guardarZonasLocalmente();
    
    // Eliminar mesas asociadas del almacenamiento local
    await _localStorage.removeTables(zona.name);
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
                          onPressed: () async {
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
                                      await _eliminarZona(z);
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
