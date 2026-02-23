import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import '../providers/visual_settings_provider.dart';
import 'package:log_in/pantallas/carta_page.dart';
import '../services/hybrid_data_service.dart';
import '../config/app_constants.dart';
import '../models/pedido.dart';

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
  List<DetallePedido> _detalles = []; // Lista para guardar los productos
  final HybridDataService _dataService = HybridDataService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _cargarCuenta();
  }

  Future<void> _cargarCuenta() async {
    try {
      if (_mesaId == null) {
        final mesas = await _dataService.obtenerMesas();
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
        final pedido = await _dataService.obtenerPedidoActivoMesa(_mesaId!);
        if (pedido != null) {
          if (mounted) {
            setState(() {
              _detalles = pedido.detalles;
              total = pedido.totalPedido;
            });
            print(
                '✅ CUENTA: Cargados ${_detalles.length} productos. Total: $total');
          }
        } else {
          print('⚠️ CUENTA: No se encontró pedido para mesa $_mesaId');
          setState(() {
            _detalles = [];
            total = 0.0;
          });
        }
      }
    } catch (e) {
      // print('Error cargando cuenta: $e');
    }
  }

  Future<void> _cargarDetalles(int pedidoId) async {
    try {
      final detallesData = await _dataService.obtenerDetallesPedido(pedidoId);
      setState(() {
        _detalles = detallesData
            .map((d) => DetallePedido.fromJson(d as Map<String, dynamic>))
            .toList();
        // Recalcular total desde detalles para asegurar sincronización
        if (_detalles.isNotEmpty) {
          total =
              _detalles.fold(0, (sum, d) => sum + (d.totalLinea ?? d.subtotal));
        }
      });
    } catch (e, stack) {
      print('💥 DIAGNÓSTICO ERROR EN _cargarDetalles: $e');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error al cargar los detalles del pedido. Inténtelo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //Método para abrir la carta
  void _abrirCarta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CartaPage(
          onAddToCuenta: (plato) async {
            if (_mesaId != null && plato.id != null) {
              try {
                // 1. Llamada al API para persistir el dato
                await _dataService.agregarProductoAMesa(_mesaId!, plato.id!);

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
        ? const Color(0xFF1E1E1E)
        : AppConstants.backgroundCream;
    final Color barraSuperior =
        settings.colorBlindMode ? Colors.blue : AppConstants.primaryGreen;
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
            height: AppConstants.appBarHeight,
            color: barraSuperior,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall),
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
                    color: settings.darkMode
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
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

                  const SizedBox(height: AppConstants.paddingSmall),

                  // === LISTA DE DETALLES ===
                  Expanded(
                    child: Card(
                      color: settings.darkMode
                          ? const Color(0xFF2C2C2C)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.05,
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: _detalles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long,
                                        size: 64,
                                        color: Colors.grey.withOpacity(0.5)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay productos en esta cuenta',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: fontSize),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _abrirCarta,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: barraSuperior),
                                      child: const Text('Ver Carta',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _detalles.length,
                                      itemBuilder: (ctx, i) {
                                        final item = _detalles[i];
                                        final nombre = item.nombreProducto;
                                        final int cantidad = item.cantidad;
                                        final double precioUnitario =
                                            item.precioUnitario;
                                        final double subtotalLinea =
                                            item.totalLinea ?? item.subtotal;

                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                barraSuperior.withOpacity(0.2),
                                            child: Text(
                                              "${cantidad}x",
                                              style: TextStyle(
                                                color: textoGeneral,
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize * 0.8,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            nombre,
                                            style: TextStyle(
                                              color: textoGeneral,
                                              fontSize: fontSize * 0.9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${precioUnitario.toStringAsFixed(2)} €/ud",
                                            style: TextStyle(
                                                fontSize: fontSize * 0.7),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${subtotalLinea.toStringAsFixed(2)} €",
                                                style: TextStyle(
                                                  color: textoGeneral,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: fontSize * 0.9,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  cantidad > 1
                                                      ? Icons
                                                          .remove_circle_outline
                                                      : Icons.delete_outline,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                                onPressed: () async {
                                                  final id = item.id;
                                                  if (id != null) {
                                                    await _dataService
                                                        .eliminarDetallePedido(
                                                            id);
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
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ElevatedButton(
                                      onPressed: _abrirCarta,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: barraSuperior,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusMedium),
                                        ),
                                      ),
                                      child: Text(
                                        'Carta +',
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // === TOTAL ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${total.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: settings.currentFontSize,
                          fontWeight: FontWeight.bold,
                          color: textoGeneral,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _mostrarConfirmacionFinalizar(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: barraSuperior,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('Finalizar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
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

  void _mostrarConfirmacionFinalizar(BuildContext context) {
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en la cuenta')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar cuenta?'),
        content: const Text(
            'Esta acción marcará el pedido como "listo" y liberará la mesa para nuevos clientes. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _finalizarCuenta();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Finalizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizarCuenta() async {
    if (_detalles.isEmpty) return;

    final pedidoId = _detalles[0].pedidoId;
    if (pedidoId != null) {
      try {
        await _dataService.finalizarPedido(pedidoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta finalizada correctamente. Mesa libre.'),
              backgroundColor: Colors.green,
            ),
          );
          // Volver a la pantalla principal para que se vea la mesa libre
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No ha sido posible finalizar la cuenta.')),
          );
        }
      }
    }
  }
}
