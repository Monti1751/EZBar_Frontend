import 'package:flutter/material.dart';
import 'package:log_in/main.dart';
import 'settings_menu.dart';
import 'cuenta.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainMenu();
  }
}

const Color mainColor = Color(0xFF7BA238);


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
    return Scaffold(
      key: _scaffoldKey,

      // === aquí cargamos el menú desde otro archivo ===
      drawer: const SettingsMenu(),

      backgroundColor: const Color(0xFFECF0D5),

      body: Column(
        children: [
          // === barra superior ===
          Container(
            height: 55,
            color: mainColor,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 28),
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
                        color: mainColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: const Text(
                        "Agregar Zona",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            decoration: const InputDecoration(
                              labelText: "Nombre de la zona",
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            if (_zoneController.text.isNotEmpty) {
                              setState(() {
                                zones.add(Zone(name: _zoneController.text));
                                _zoneController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: zones.map((z) => ZoneWidget(zone: z, onDelete: () {  },)).toList(),
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

// === MODELO DE ZONA ===
class Zone {
  String name;
  bool isOpen = false;
  List<Table> tables = [];

  Zone({required this.name});
}

// === MODELO DE MESA ===
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

  // Método para cambiar el estado basado en código numérico (como en Java)
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
        estado = "libre"; // valor por defecto en caso de error
    }
  }

  // Método para obtener el color según el estado
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
    }
  }
}

// === WIDGET ZONA ===
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.zone.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(widget.zone.isOpen ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                widget.zone.isOpen = !widget.zone.isOpen;
              });
            },
          ),

          if (widget.zone.isOpen)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
                          
                          // Botones para cambiar estado
                          Row(
                            children: [
                              // Botón para cambiar estado
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
                              
                              // Botón eliminar
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

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tableController,
                          decoration: const InputDecoration(
                            labelText: "Nombre de la mesa",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_tableController.text.isNotEmpty) {
                            setState(() {
                              widget.zone.tables.add(Table(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _tableController.text,
                                ubicacion: widget.zone.name,
                                numeroMesa: _tableCounter++,
                                capacidad: 4, // Capacidad por defecto
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