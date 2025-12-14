import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import 'visual_settings_provider.dart';
import 'CartaPage.dart';
import 'services/api_service.dart';
import 'plato.dart'; // Importante para el modelo

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;
  // Podrías pasar también el ID de la mesa si lo tienes:
  final int? mesaId;

  const CuentaMesaPage({super.key, required this.nombreMesa, this.mesaId});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;
  List<dynamic> detallesPedido = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _cargarCuenta();
  }

  Future<void> _cargarCuenta() async {
    setState(() => isLoading = true);
    try {
      // 1. Necesitamos saber el ID de la mesa para buscar su pedido.
      // Si no viene en el widget, tendrías que buscar la mesa por nombre primero o pasarlo.
      // Asumiremos por ahora que widget.mesaId viene o hacemos una búsqueda básica.

      int? idMesa = widget.mesaId;

      // Si no tenemos ID, intentamos buscar la mesa por nombre (esto requiere un endpoint extra o filtrar todas)
      if (idMesa == null) {
        final mesas = await _apiService.obtenerMesas();
        final mesaEncontrada = mesas.firstWhere(
          (m) =>
              m['numero_mesa'].toString() ==
              widget.nombreMesa.replaceAll(RegExp(r'[^0-9]'), ''),
          orElse: () => null,
        );
        if (mesaEncontrada != null) {
          idMesa = mesaEncontrada['mesa_id'];
        }
      }

      if (idMesa != null) {
        final pedido = await _apiService.obtenerPedidoActivoMesa(idMesa);
        if (pedido != null) {
          setState(() {
            total = (pedido['total_pedido'] as num).toDouble();
            // Si el endpoint de pedido devuelve los detalles (productos), los cargaríamos aquí.
            // Si no, habría que llamar a otro endpoint /pedidos/{id}/detalles
            // Por ahora solo mostramos el total global.
          });
        } else {
          setState(() => total = 0.0);
        }
      }
    } catch (e) {
      print('Error cargando cuenta: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Método para abrir la carta
  void _abrirCarta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CartaPage(
          onAddToCuenta: (plato) async {
            // Aquí deberíamos llamar a la API para añadir el producto al pedido real
            // Por simplicidad visual inmediata, sumamos localmente, pero lo ideal es:
            // await _apiService.agregarProductoAPedido(pedidoId, plato.id);
            // _cargarCuenta();

            setState(() {
              total += plato.precio;
            });
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
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === TOTAL ===
                  Row(
                    children: [
                      isLoading
                          ? const CircularProgressIndicator()
                          : Text(
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
