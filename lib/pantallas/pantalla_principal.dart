import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import '../services/hybrid_data_service.dart';
import '../services/local_storage_service.dart';
import '../models/zona.dart';
import '../providers/visual_settings_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/add_zone_button.dart';
import '../widgets/add_zone_field.dart';
import '../widgets/zona_widget.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainMenu();
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HybridDataService _dataService = HybridDataService();
  final LocalStorageService _localStorage = LocalStorageService();

  bool _showAddZoneField = false;
  final TextEditingController _zoneController = TextEditingController();
  List<Zona> zones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🔄 PantallaPrincipal initState: comenzando carga de zonas...');
    _cargarZonas();
  }

  Future<void> _cargarZonas() async {
    print('📥 _cargarZonas() iniciado');
    try {
      final zonasData = await _dataService.obtenerZonas();
      print('📦 Datos de zonas recibidos: ${zonasData.length} zonas');
      setState(() {
        zones = zonasData.map((z) {
          print('🔍 Parseando zona: ${z['nombre']}');
          return Zona.fromJson(z);
        }).toList();
        _isLoading = false;
      });
      
      print('✅ Zonas cargadas: ${zones.length}');
      await _localStorage.saveZones(zones);
    } catch (e) {
      print('❌ Error al cargar zonas: $e');
      final locales = await _localStorage.getZones();
      setState(() {
        zones = locales;
        _isLoading = false;
      });
    }
  }

  Future<void> _crearZona(String nombre) async {
    if (nombre.trim().isEmpty) return;

    try {
      final response = await _dataService.crearZona({'nombre': nombre});
      final nueva = Zona.fromJson(response);

      setState(() {
        zones.add(nueva);
        _zoneController.clear();
        _showAddZoneField = false;
      });

      await _localStorage.saveZones(zones);
    } catch (_) {
      final nueva = Zona(
        nombre: nombre,
        totalMesas: 0,
        mesasLibres: 0,
        mesasOcupadas: 0,
      );

      setState(() {
        zones.add(nueva);
        _zoneController.clear();
        _showAddZoneField = false;
      });

      await _localStorage.saveZones(zones);
    }
  }

  Future<void> _eliminarZona(Zona zona) async {
    try {
      await _dataService.eliminarZona(zona.nombre);
    } catch (_) {}

    setState(() => zones.remove(zona));
    await _localStorage.saveZones(zones);
    await _localStorage.removeTables(zona.nombre);
  }

  void _toggleAddZoneField() {
    setState(() => _showAddZoneField = !_showAddZoneField);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          TopBar(
            scaffoldKey: _scaffoldKey,
            backgroundColor: barraSuperior,
            settings: settings,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  AddZoneButton(
                    onTap: _toggleAddZoneField,
                    backgroundColor: barraSuperior,
                    settings: settings,
                  ),
                  const SizedBox(height: 10),
                  if (_showAddZoneField)
                    AddZoneField(
                      controller: _zoneController,
                      onSubmit: _crearZona,
                      buttonColor: barraSuperior,
                      settings: settings,
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: barraSuperior))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: Center(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.start,
                                    children: zones.map((z) {
                                      return SizedBox(
                                        width: constraints.maxWidth > 600
                                            ? (constraints.maxWidth / 2) -
                                                18 // 2 columns minus spacing
                                            : constraints.maxWidth, // 1 column
                                        child: ZoneWidget(
                                          zona: z,
                                          onDelete: () => _eliminarZona(z),
                                        ),
                                      );
                                    }).toList(),
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
  }
}