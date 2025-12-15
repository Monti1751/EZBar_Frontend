import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import 'visual_settings_provider.dart';
import 'CartaPage.dart'; // 👈 Importamos la pantalla de la carta
import 'services/api_service.dart';

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;

  const CuentaMesaPage({super.key, required this.nombreMesa});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;
  int? _mesaId;
  List<dynamic> detalles = [];
  final ApiService _apiService = ApiService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _cargarCuenta();
  }

  Future<void> _cargarCuenta() async {
    try {
      if (_mesaId == null) {
        final mesas = await _apiService.obtenerMesas();
        final mesaEncontrada = mesas.firstWhere((m) {
          final numeroStr = m['numero_mesa'].toString();
          final numeroEnNombre = widget.nombreMesa.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
          return (numeroEnNombre.isNotEmpty && numeroStr == numeroEnNombre) ||
              (m['nombre'] != null && m['nombre'] == widget.nombreMesa);
        }, orElse: () => null);

        if (mesaEncontrada != null) {
          _mesaId = mesaEncontrada['mesa_id'];
        }
      }

      if (_mesaId != null) {
        final pedido = await _apiService.obtenerPedidoActivoMesa(_mesaId!);
        if (pedido != null) {
          final pedidoId = pedido['pedido_id'] ?? pedido['id'] ?? null;
          List<dynamic> detallesResp = [];
          if (pedidoId != null) {
            detallesResp = await _apiService.obtenerDetallesPedido(pedidoId);
          }
          setState(() {
            total = (pedido['total_pedido'] as num).toDouble();
            detalles = detallesResp;
          });
        }
      }
    } catch (e) {
      print('Error cargando cuenta: $e');
    }
  }

  // 👇 Método para abrir la carta
  void _abrirCarta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CartaPage(
          // Callback: agregar producto y actualizar UI con respuesta del servidor
          onAddToCuenta: (plato) async {
            if (_mesaId != null && plato.id != null) {
              try {
                final resp = await _apiService.agregarProductoAMesa(_mesaId!, plato.id!);
                if (resp != null) {
                  setState(() {
                    total = (resp['total_pedido'] as num).toDouble();
                    detalles = resp['detalles'] ?? detalles;
                  });
                }
              } catch (e) {
                print("Error adding product: $e");
              }
            }
          },
        ),
      ),
    ).then((_) => _cargarCuenta()); // Recargar al volver
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores dinámicos según ajustes
    final Color fondo = settings.darkMode
        ? Colors.black
        : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;

    // Tamaños de letra dinámicos
    final double fontSize = settings.currentFontSize;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,

      body: Column(
        children: [
          // === BARRA SUPERIOR ===
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // === CUADRO PARA EL NOMBRE DE LA MESA ===
                  Card(
                    color: settings.darkMode ? Colors.grey[850] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          widget.nombreMesa,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: textoGeneral,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // === CONTENEDOR PARA LA CARTA ===
                  Expanded(
                    child: Card(
                      color: settings.darkMode
                          ? Colors.grey[850]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.05,
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: _abrirCarta, // 👈 Conectado con CartaPage
                            style: ElevatedButton.styleFrom(
                              backgroundColor: barraSuperior,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 50,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Carta +',
                              style: TextStyle(
                                fontSize: settings.currentFontSize,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === DETALLES DEL PEDIDO ===
                  SizedBox(
                    height: 180,
                    child: detalles.isEmpty
                        ? Center(
                            child: Text(
                              'No hay productos en la cuenta',
                              style: TextStyle(color: textoGeneral),
                            ),
                          )
                        : ListView.builder(
                            itemCount: detalles.length,
                            itemBuilder: (ctx, i) {
                              final d = detalles[i];
                              final nombre = d['producto_nombre'] ?? 'Producto';
                              final cantidad = (d['cantidad'] is num) ? d['cantidad'].toString() : '${d['cantidad']}';
                              final linea = (d['total_linea'] is num) ? (d['total_linea'] as num).toDouble() : 0.0;
                              return ListTile(
                                title: Text(nombre, style: TextStyle(color: textoGeneral)),
                                subtitle: Text('Cantidad: $cantidad', style: TextStyle(color: textoGeneral)),
                                trailing: Text('${linea.toStringAsFixed(2)} €', style: TextStyle(color: textoGeneral)),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // === TOTAL ===
                  Row(
                    children: [
                      Text(
                        'Total: ${total.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: settings.currentFontSize,
                          fontWeight: FontWeight.bold,
                          color: textoGeneral,
                        ),
                      ),
                    ],
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
