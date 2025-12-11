import 'package:flutter/material.dart';
import 'settings_menu.dart';
import 'package:provider/provider.dart';
import 'cuenta.dart';
import 'visual_settings_provider.dart';

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
  String name;
  bool isOpen = false;
  List<Mesa> tables = [];

  Zone({required this.name});
}

/// === MODELO DE MESA ===
class Mesa {
  String id;
  String name;
  String estado; // "libre", "reservado", "ocupado"
  String ubicacion;
  int numeroMesa;
  int capacidad;

  Mesa({
    required this.id,
    required this.name,
    required this.ubicacion,
    required this.numeroMesa,
    required this.capacidad,
    this.estado = "libre",
  });

  void setEstado(int disposicion) {
    switch (disposicion) {
      case 1:
        estado = "libre";
        break;
      case 2:
        estado = "reservado";
        break;
      case 3:
        estado = "ocupado";
        break;
      default:
        estado = "libre";
    }
  }

  Color getColorByEstado(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context, listen: false);
    if (settings.colorBlindMode) {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.blue;
        case 'reservado':
          return Colors.orange;
        case 'ocupado':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    } else {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.green;
        case 'reservado':
          return Colors.orange;
        case 'ocupado':
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
          // El badge se mantiene en 12 para legibilidad
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ).copyWith(color: color),
      ),
    );
  }
}

/// === WIDGET ZONA ===
class ZoneWidget extends StatefulWidget {
  final Zone zone;
  final VoidCallback onDelete;

  const ZoneWidget({super.key, required this.zone, required this.onDelete});

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  final TextEditingController _tableController = TextEditingController();
  int _tableCounter = 1;

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context, listen: false);
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
              decoration: InputDecoration(
                hintText: 'Nombre de la mesa',
                filled: true,
                fillColor: settings.darkMode ? Colors.grey[800] : Colors.white,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
              style: TextStyle(color: settings.darkMode ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.add,
              color: settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238),
            ),
            onPressed: () {
              if (_tableController.text.isNotEmpty) {
                setState(() {
                  widget.zone.tables.add(
                    Mesa(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _tableController.text,
                      ubicacion: widget.zone.name,
                      numeroMesa: _tableCounter++,
                      capacidad: 4,
                    ),
                  );
                  _tableController.clear();
                });
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
    final Color tarjetaZona = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: textoZona),
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
                        content: Text("¿Seguro que quieres eliminar la zona '${widget.zone.name}'?"),
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
                            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Icon(widget.zone.isOpen ? Icons.expand_less : Icons.expand_more, color: textoZona),
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
                                    builder: (context) => CuentaMesaPage(nombreMesa: table.name),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: _cardDecoration(context),
                                child: Row(
                                  // Corrección aquí: spaceBetween (camelCase)
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                color: settings.darkMode ? Colors.white : Colors.black,
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
                                            color: settings.darkMode ? Colors.white70 : Colors.black54,
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
                                                  Icon(Icons.circle, color: Colors.green),
                                                  SizedBox(width: 8),
                                                  Text('Libre'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'reservado',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.circle, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text('Reservado'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'ocupado',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.circle, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Ocupado'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text("Confirmar eliminación"),
                                                content: Text("¿Seguro que quieres eliminar la mesa '${table.name}'?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(ctx).pop(),
                                                    child: const Text("Cancelar"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        widget.zone.tables.remove(table);
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

/// Menú principal con estado
class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showAddZoneField = false;
  final TextEditingController _zoneController = TextEditingController();
  List<Zone> zones = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    // Colores y tamaños dinámicos según ajustes
    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final double fontSize = settings.currentFontSize;
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

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
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
          ),

          // Contenido principal
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
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textoGeneral),
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
                            decoration: InputDecoration(
                              hintText: "Nombre de la zona",
                              filled: true,
                              fillColor: settings.darkMode ? Colors.grey[800] : Colors.white,
                              hintStyle: TextStyle(color: textoGeneral),
                              border: const OutlineInputBorder(),
                            ),
                            style: TextStyle(color: textoGeneral),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.check, color: barraSuperior),
                          onPressed: () {
                            if (_zoneController.text.isNotEmpty) {
                              setState(() {
                                zones.add(Zone(name: _zoneController.text));
                                _zoneController.clear();
                                _showAddZoneField = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  // Lista de zonas
                  Expanded(
                    child: ListView(
                      children: zones
                          .map(
                            (z) => ZoneWidget(
                              zone: z,
                              onDelete: () {
                                setState(() {
                                  zones.remove(z);
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
