import 'package:flutter/material.dart';
import 'package:log_in/main.dart';
import 'settings_menu.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
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

  bool _showAddZoneField = false;                 // Controla si se muestra el campo para agregar zona
  final TextEditingController _zoneController = TextEditingController(); // Controlador de texto para la zona
  List<Zone> zones = [];                          // Lista de zonas creadas

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores y tamaños dinámicos según ajustes
    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
    final double fontSize = settings.smallFont ? 14 : 18;
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      key: _scaffoldKey,

      // Menú lateral cargado desde otro archivo
      // Menú lateral
      drawer: const SettingsMenu(),

      backgroundColor: fondo,

      body: Column(
        children: [
          // === Barra superior ===
          // Barra superior
          Container(
            height: 55,
            color: barraSuperior,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón para abrir el menú lateral
                IconButton(
                  icon: Icon(Icons.menu, color: textoGeneral, size: 28),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
          ),

          // === Contenido principal ===
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Botón "Agregar Zona"
                  GestureDetector(
                    onTap: () {
                      // Alterna mostrar / ocultar campo de texto
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

                  // Campo para escribir el nombre de la zona
                  if (_showAddZoneField)
                    Row(
                      children: [
                        Expanded
                        (
                          child: TextField(
                            controller: _zoneController,
                            decoration: InputDecoration(
                              labelText: "Nombre de la zona",
                              filled: true,
                              fillColor: settings.darkMode ? Colors.grey[800] : Colors.white,
                              labelStyle: TextStyle(color: textoGeneral),
                            ),
                            style: TextStyle(color: textoGeneral),
                          ),
                        ),

                        // Botón para confirmar agregar zona
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

                  // Lista de zonas creadas
                  Expanded(
                    child: ListView(
                      children: zones.map((z) => ZoneWidget(
                        zone: z,
                        onDelete: () {}, // (pendiente implementar)
                      )).toList(),
                      children: zones
                          .map((z) => ZoneWidget(zone: z, onDelete: () {
                                setState(() {
                                  zones.remove(z);
                                });
                              }))
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


/// === MODELO DE ZONA ===
/// Contiene nombre, estado (si está expandida o no)
/// y lista de mesas dentro de la zona
class Zone {
  String name;
  bool isOpen = false;
  List<Table> tables = [];

  Zone({required this.name});
}


/// === MODELO DE MESA ===
/// Representa una mesa dentro de una zona
class Table {
  String id;
  String name;
  String estado; // "libre", "reservado", "ocupado"
  String ubicacion;
  int numeroMesa;
  int capacidad;
  bool activa;

  Table({
    required this.id,
    required this.name,
    required this.ubicacion,
    required this.numeroMesa,
    required this.capacidad,
    this.estado = "libre",
    this.activa = true,
  });

  /// Cambia estado según número (similar a Java)
  // Método para cambiar el estado basado en código numérico
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

  /// Devuelve color según estado
  Color getColorByEstado() {
    switch (estado.toLowerCase()) {
      case "libre":
        return Colors.green;
      case "reservado":
        return Colors.orange;
      case "ocupado":
        return Colors.red;
      default:
        return Colors.grey;
  // Color según estado y daltonismo
  Color getColorByEstado(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context, listen: false);

    if (settings.colorBlindMode) {
      switch (estado.toLowerCase()) {
        case "libre":
          return Colors.blue;     // alternativa al verde
        case "reservado":
          return Colors.orange;   // mantenemos naranja
        case "ocupado":
          return Colors.purple;   // alternativa al rojo
        default:
          return Colors.grey;
      }
    } else {
      switch (estado.toLowerCase()) {
        case "libre":
          return Colors.green;
        case "reservado":
          return Colors.orange;
        case "ocupado":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }
}


/// === WIDGET ZONA ===
/// Muestra una zona desplegable con sus mesas
class ZoneWidget extends StatefulWidget {
  final Zone zone;
  final VoidCallback onDelete;

  const ZoneWidget({super.key, required this.zone, required this.onDelete});

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  final TextEditingController _tableController = TextEditingController();
  int _tableCounter = 1; // Contador para numerar mesas

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);
    final double fontSize = settings.smallFont ? 14 : 18;
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

          // Encabezado de zona (abre/cierra)
          // Cabecera de la zona
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
                  icon: Icon(Icons.delete_outline, color: textoZona),
                  onPressed: widget.onDelete,
                ),
                Icon(widget.zone.isOpen ? Icons.expand_less : Icons.expand_more, color: textoZona),
              ],
            ),
            onTap: () {
              setState(() {
                widget.zone.isOpen = !widget.zone.isOpen;
              });
            },
          ),

          // Si la zona está abierta, se muestran las mesas
          if (widget.zone.isOpen)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [

                  // === LISTA DE MESAS ===
                  for (var table in widget.zone.tables)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: table.getColorByEstado(),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black45),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // Información textual de la mesa
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  table.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Estado: ${table.estado}",
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // === BOTONES DE ACCIÓN DE LA MESA ===
                          Row(
                            children: [

                              /// Menú para cambiar estado (libre, reservado, ocupado)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
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
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'libre',
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Libre'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reservado',
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Reservado'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
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

                              /// Botón para eliminar mesa
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    widget.zone.tables.remove(table);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                  // Lista de mesas
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
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: table.getColorByEstado(context),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black45),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Info mesa
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    table.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSize,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Estado: ${table.estado}",
                                    style: TextStyle(
                                      fontSize: settings.smallFont ? 12 : 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Acciones mesa
                            Row(
                              children: [
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  onSelected: (String value) {
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
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'libre',
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Libre'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'reservado',
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, color: Colors.orange),
                                          SizedBox(width: 8),
                                          Text('Reservado'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
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
                                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      widget.zone.tables.remove(table);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // === CAMPO PARA AGREGAR MESA NUEVA ===
                  // Añadir mesa
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tableController,
                          decoration: InputDecoration(
                            labelText: "Nombre de la mesa",
                            filled: true,
                            fillColor: settings.darkMode ? Colors.grey[800] : Colors.white,
                            labelStyle: TextStyle(color: textoZona),
                          ),
                          style: TextStyle(color: textoZona),
                        ),
                      ),

                      // Botón para agregar nueva mesa
                      IconButton(
                        icon: Icon(Icons.add, color: textoZona),
                        onPressed: () {
                          if (_tableController.text.isNotEmpty) {
                            setState(() {
                              widget.zone.tables.add(Table(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _tableController.text,
                                ubicacion: widget.zone.name,
                                numeroMesa: _tableCounter++,
                                capacidad: 4,
                              ));
                              _tableController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
