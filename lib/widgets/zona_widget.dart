import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zona.dart';
import '../models/mesa.dart';
import '../providers/visual_settings_provider.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../pantallas/cuenta.dart';
import '../l10n/app_localizations.dart';

class ZoneWidget extends StatefulWidget {
  final Zona zona;
  final VoidCallback onDelete;

  const ZoneWidget({super.key, required this.zona, required this.onDelete});

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  bool _isExpanded = false;
  final TextEditingController _tableController = TextEditingController();
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();
  List<Mesa> _mesas = [];
  int _tableCounter = 1;

  @override
  void initState() {
    super.initState();
    _cargarMesasDeZona();
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _cargarMesasDeZona() async {
    try {
      final mesas = await _apiService.obtenerMesasPorZona(widget.zona.nombre);
      final deletedIds = await _localStorage.getDeletedTables();

      if (mounted) {
        setState(() {
          _mesas = mesas
              .where((m) => !deletedIds.contains(m['mesa_id']))
              .map((m) => Mesa.fromJson(m))
              .toList();

          if (_mesas.isNotEmpty) {
            final maxNumero = _mesas
                .map((m) => m.numeroMesa)
                .reduce((curr, next) => curr > next ? curr : next);
            _tableCounter = maxNumero + 1;
          }
        });
        await _guardarMesasLocalmente();
      }
    } catch (e) {
      await _cargarMesasLocalmente();
    }
  }

  Future<void> _guardarMesasLocalmente() async {
    try {
      await _localStorage.saveTables(widget.zona.nombre, _mesas);
    } catch (e) {
      // print('Error guardando mesas localmente: $e');
    }
  }

  Future<void> _cargarMesasLocalmente() async {
    try {
      final mesasLocales = await _localStorage.getTables(widget.zona.nombre);
      if (mesasLocales.isNotEmpty && mounted) {
        setState(() {
          _mesas = mesasLocales;
          if (_mesas.isNotEmpty) {
            final maxNumero = _mesas
                .map((m) => m.numeroMesa)
                .reduce((curr, next) => curr > next ? curr : next);
            _tableCounter = maxNumero + 1;
          }
        });
      }
    } catch (e) {
      // print('Error cargando mesas localmente: $e');
    }
  }

  Future<void> _agregarMesa() async {
    if (_tableController.text.isEmpty) return;

    final nuevaMesa = Mesa(
      id: '',
      name: _tableController.text,
      ubicacion: widget.zona.nombre,
      numeroMesa: _tableCounter++,
      capacidad: 4,
      estado: 'libre',
    );

    try {
      final mesaData = {
        'nombre': nuevaMesa.name,
        'ubicacion': nuevaMesa.ubicacion,
        'numero_mesa': nuevaMesa.numeroMesa,
        'capacidad': nuevaMesa.capacidad,
        'estado': nuevaMesa.estado,
      };
      final response = await _apiService.crearMesa(mesaData);
      if (response['mesa_id'] != null) {
        nuevaMesa.id = response['mesa_id'].toString();
      }
    } catch (e) {
      nuevaMesa.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    setState(() {
      _mesas.add(nuevaMesa);
      _tableController.clear();
    });

    await _guardarMesasLocalmente();
  }

  Future<void> _eliminarMesa(Mesa mesa) async {
    try {
      if (mesa.id.isNotEmpty && int.tryParse(mesa.id) != null) {
        await _apiService.eliminarMesa(int.parse(mesa.id));
        await _localStorage.addDeletedTable(int.parse(mesa.id));
      }
    } catch (e) {
      // print('Error eliminando mesa: $e');
    }

    setState(() {
      _mesas.remove(mesa);
    });

    await _guardarMesasLocalmente();
  }

  Future<void> _cambiarEstadoMesa(Mesa mesa, String nuevoEstado) async {
    setState(() {
      mesa.estado = nuevoEstado;
    });

    await _guardarMesasLocalmente();

    try {
      if (mesa.id.isNotEmpty && int.tryParse(mesa.id) != null) {
        await _apiService.actualizarMesa(int.parse(mesa.id), {
          'estado': mesa.estado,
        });
      }
    } catch (e) {
      // print('Error actualizando mesa en backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color backgroundColor = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final Color textColor = settings.darkMode ? Colors.white : Colors.black;
    final Color cardColor = settings.darkMode
        ? Colors.grey[850]!
        : Colors.white;
    final double fontSize = settings.currentFontSize;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.zona.nombre,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Evitar que se propague el tap
                          widget.onDelete();
                        },
                        child: Icon(Icons.delete, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded)
          if (_isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black26),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo para agregar mesa
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tableController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                  .translate('table_name_hint'),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.table_restaurant_outlined,
                                color: Color(0xFF4A4025),
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFFFFF),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF4A4025),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF7BA238),
                                  width: 2.2,
                                ),
                              ),
                            ),
                            style:
                                TextStyle(color: Colors.black), // Force input text black as bg is white
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add, color: backgroundColor),
                          onPressed: _agregarMesa,
                        ),
                      ],
                    ),
                  ),

                  // Lista de mesas
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _mesas.length,
                      itemBuilder: (context, index) {
                        final mesa = _mesas[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CuentaMesaPage(
                                  nombreMesa: mesa.name,
                                  nombreZona: widget.zona.nombre,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      mesa.getEstadoBadge(context),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          mesa.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: textColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      onSelected: (value) {
                                        _cambiarEstadoMesa(mesa, value);
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'libre',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: settings.colorBlindMode
                                                    ? Colors.blue
                                                    : Colors.green,
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
                                                color: settings.colorBlindMode
                                                    ? Colors.purple
                                                    : Colors.red,
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
                                              'Eliminar mesa',
                                            ),
                                            content: Text(
                                              '¿Eliminar "${mesa.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _eliminarMesa(mesa);
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text(
                                                  'Eliminar',
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
