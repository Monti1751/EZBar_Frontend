import 'package:flutter/material.dart'; 
import 'settings_menu.dart';

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;

  const CuentaMesaPage({super.key, required this.nombreMesa});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _abrirCarta() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      endDrawer: const SettingsMenu(),

      body: Column(
        children: [
          // === BARRA SUPERIOR ===
          Container(
            height: 55,
            color: const Color(0xFF7BA238),
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
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

                  // === NUEVO CUADRO BLANCO PARA EL NOMBRE DE LA MESA ===
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          widget.nombreMesa,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4025),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === CONTENEDOR BLANCO MÁS GRANDE PARA LA CARTA ===
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0), // más grande
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Acceder a la carta',
                              style: TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _abrirCarta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7BA238),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 40,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Carta +',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
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
                  Text(
                    'Total: ${total.toStringAsFixed(2)} \€',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4025),
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