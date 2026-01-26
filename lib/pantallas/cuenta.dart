import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import '../providers/visual_settings_provider.dart';
import 'package:log_in/pantallas/carta_page.dart'; // 👈 Importamos la pantalla de la carta
import '../services/api_service.dart';

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;
  final String? nombreZona; // Zona de la mesa

  const CuentaMesaPage({super.key, required this.nombreMesa, this.nombreZona});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;
  int? _mesaId;
  List<dynamic> _detalles = []; // Lista para guardar los productos
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
          // Primero verificar que coincida el nombre o número
          final numeroStr = m['numero_mesa'].toString();
          final numeroEnNombre = widget.nombreMesa.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
          final nombreCoincide =
              (numeroEnNombre.isNotEmpty && numeroStr == numeroEnNombre) ||
              (m['nombre'] != null && m['nombre'] == widget.nombreMesa);

          // Si hay zona especificada, también debe coincidir
          if (widget.nombreZona != null) {
            final zonaCoincide = m['ubicacion'] == widget.nombreZona;
            return nombreCoincide && zonaCoincide;
          }

          return nombreCoincide;
        }, orElse: () => null);

        if (mesaEncontrada != null) {
          _mesaId = mesaEncontrada['mesa_id'];
        }
      }

      if (_mesaId != null) {
        final pedido = await _apiService.obtenerPedidoActivoMesa(_mesaId!);
        if (pedido != null) {
          // Primero actualizamos el total del pedido
          setState(() {
            final totalPedido = pedido['total_pedido'];
            // Manejar tanto String como num
            if (totalPedido is String) {
              total = double.tryParse(totalPedido) ?? 0.0;
            } else if (totalPedido is num) {
              total = totalPedido.toDouble();
            } else {
              total = 0.0;
            }
          });
          // Luego cargamos los detalles
          await _cargarDetalles(pedido['pedido_id']);
        }
      }
    } catch (e) {
      // print('Error cargando cuenta: $e');
    }
  }

  Future<void> _cargarDetalles(int pedidoId) async {
    try {
      final detalles = await _apiService.obtenerDetallesPedido(pedidoId);
      setState(() {
        _detalles = detalles;
        // Recalcular total desde detalles para asegurar sincronización
        if (_detalles.isNotEmpty) {
          double sum = 0;
          for (var d in _detalles) {
            // Check for null price or total_linea
            // The backend returns 'total_linea' or 'precio_unitario'
            // Try multiple field names for robustness (snake_case vs camelCase)
            // and fallback to nested product price
            final precio =
                d['total_linea'] ??
                d['totalLinea'] ??
                d['precio_unitario'] ??
                d['precioUnitario'] ??
                d['precio'] ??
                (d['producto'] != null ? d['producto']['precio'] : null);

            if (precio != null) {
              // Manejar tanto String como num
              if (precio is String) {
                sum += double.tryParse(precio) ?? 0.0;
              } else if (precio is num) {
                sum += precio.toDouble();
              }
            }
          }
          total = sum;
        }
      });
    } catch (e) {
      // print('Error cargando detalles: $e');
    }
  }

  // 👇 Método para abrir la carta
  void _abrirCarta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CartaPage(
          onAddToCuenta: (plato) async {
            if (_mesaId != null && plato.id != null) {
              try {
                // 1. Llamada al API para persistir el dato
                await _apiService.agregarProductoAMesa(_mesaId!, plato.id!);

                // 2. Refrescar los datos del servidor para obtener la lista actualizada
                // con los IDs de detalle correctos y cantidades.
                await _cargarCuenta();
              } catch (e) {
                // print("Error adding product: $e");
              }
            }
          },
        ),
      ),
    ).then((_) => _cargarCuenta()); // Sincronización final al cerrar la carta
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

    // Nuevo sistema de tamaños (pequeño, mediano, grande)
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

                  // === LISTA DE DETALLES ===
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
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: _detalles.length,
                                itemBuilder: (ctx, i) {
                                  final item = _detalles[i];
                                  final producto = item['producto'];

                                  // Extraer datos con fallbacks de seguridad y conversión de tipos
                                  final nombre =
                                      producto?['nombre'] ??
                                      item['nombre'] ??
                                      'Producto';
                                  final cantidad = item['cantidad'] ?? 1;

                                  // Convertir precio unitario (puede ser String o num)
                                  final precioRaw =
                                      producto?['precio'] ??
                                      item['precio_unitario'] ??
                                      0;
                                  final precioUnitario = precioRaw is String
                                      ? (double.tryParse(precioRaw) ?? 0.0)
                                      : (precioRaw as num).toDouble();

                                  // Convertir subtotal (puede ser String o num)
                                  final subtotalRaw =
                                      item['total_linea'] ??
                                      (precioUnitario * cantidad);
                                  final subtotalLinea = subtotalRaw is String
                                      ? (double.tryParse(subtotalRaw) ?? 0.0)
                                      : (subtotalRaw as num).toDouble();

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: barraSuperior.withValues(
                                        alpha: 0.2,
                                      ),
                                      child: Text(
                                        "${cantidad}x",
                                        style: TextStyle(
                                          color: textoGeneral,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      nombre,
                                      style: TextStyle(
                                        color: textoGeneral,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${precioUnitario.toStringAsFixed(2)} €/ud",
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${subtotalLinea.toStringAsFixed(2)} €",
                                          style: TextStyle(
                                            color: textoGeneral,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final id = item['detalle_id'];
                                            if (id != null) {
                                              await _apiService
                                                  .eliminarDetallePedido(id);
                                              _cargarCuenta();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: _abrirCarta,
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
