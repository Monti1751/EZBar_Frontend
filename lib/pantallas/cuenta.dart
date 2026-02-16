import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import '../providers/visual_settings_provider.dart';
import 'package:log_in/pantallas/carta_page.dart'; // 👈 Importamos la pantalla de la carta
import '../services/hybrid_data_service.dart';
import '../config/app_constants.dart';

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
      final detalles = await _dataService.obtenerDetallesPedido(pedidoId);
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
            final precio = d['total_linea'] ??
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
    final Color fondo =
        settings.darkMode ? Colors.black : AppConstants.backgroundCream;
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
                    color: settings.darkMode ? Colors.grey[850] : Colors.white,
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
                      color:
                          settings.darkMode ? Colors.grey[850] : Colors.white,
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
                                  final nombre = producto?['nombre'] ??
                                      item['nombre'] ??
                                      'Producto';

                                  // Asegurar que cantidad sea un entero (puede venir como String "1.00" o double 1.0)
                                  final cantidadRaw = item['cantidad'] ?? 1;
                                  final int cantidad = cantidadRaw is String
                                      ? (double.tryParse(cantidadRaw)
                                              ?.toInt() ??
                                          1)
                                      : (cantidadRaw as num).toInt();

                                  // Convertir precio unitario (puede ser String o num)
                                  final precioRaw = producto?['precio'] ??
                                      item['precio_unitario'] ??
                                      0;
                                  final double precioUnitario =
                                      precioRaw is String
                                          ? (double.tryParse(precioRaw) ?? 0.0)
                                          : (precioRaw as num).toDouble();

                                  // Convertir subtotal (puede ser String o num)
                                  final subtotalRaw = item['total_linea'] ??
                                      (precioUnitario * cantidad);
                                  final double subtotalLinea = subtotalRaw
                                          is String
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
                                        // Botón de Restar (Eliminar uno)
                                        IconButton(
                                          icon: Icon(
                                            cantidad > 1
                                                ? Icons.remove_circle_outline
                                                : Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final id = item['detalle_id'];
                                            if (id != null) {
                                              await _dataService
                                                  .eliminarDetallePedido(id);
                                              _cargarCuenta();
                                            }
                                          },
                                        ),
                                        // Cantidad central (opcional, ya la tienes en el leading, pero aquí queda muy intuitivo)
                                        Text(
                                          "${subtotalLinea.toStringAsFixed(2)} €",
                                          style: TextStyle(
                                            color: textoGeneral,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                        // Botón de Sumar (Añadir uno)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.green,
                                          ),
                                          onPressed: () async {
                                            if (_mesaId != null &&
                                                item['producto_id'] != null) {
                                              await _dataService
                                                  .agregarProductoAMesa(
                                                      _mesaId!,
                                                      item['producto_id']);
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
                                    vertical:
                                        AppConstants.buttonPaddingVerticalLarge,
                                    horizontal: 50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadiusMedium),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar cuenta?'),
        content: const Text(
            'Esta acción marcará el pedido como pagado y liberará la mesa. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _finalizarCuenta();
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
    if (_detalles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay productos en la cuenta')),
        );
      }
      return;
    }

    final pedidoId = _detalles[0]['pedido_id'];
    if (pedidoId != null) {
      try {
        await _dataService.finalizarPedido(pedidoId);
        await _cargarCuenta();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta finalizada correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
