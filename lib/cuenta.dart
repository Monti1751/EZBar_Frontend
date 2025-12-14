import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_menu.dart';
import 'visual_settings_provider.dart';
import 'CartaPage.dart'; // 👈 Importamos la pantalla de la carta

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;

  const CuentaMesaPage({super.key, required this.nombreMesa});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 👇 Método para abrir la carta
  void _abrirCarta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CartaPage(
          // Callback opcional: suma el precio del plato al total
          onAddToCuenta: (plato) {
            setState(() {
              total += plato.precio;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    // Colores dinámicos según ajustes
    final Color fondo = settings.darkMode ? Colors.black : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode ? Colors.blue : const Color(0xFF7BA238);
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
                      color: settings.darkMode ? Colors.grey[850] : Colors.white,
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
