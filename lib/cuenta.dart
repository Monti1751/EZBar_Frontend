import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'settings_menu.dart';

class CuentaMesaPage extends StatefulWidget {
  final String nombreMesa;

  const CuentaMesaPage({super.key, required this.nombreMesa});

  @override
  State<CuentaMesaPage> createState() => _CuentaMesaPageState();
}

class _CuentaMesaPageState extends State<CuentaMesaPage> {
  double total = 0.0;

  void _abrirCarta() {
    // Aquí iría la navegación a la pantalla de la carta
    // Por ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => CartaPage()));
    // Para demo, sumamos un valor al total
    setState(() {
      total += 25.0; // simula agregar un producto
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuenta de ${widget.nombreMesa}'),
      ),
      drawer: const SettingsMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nombre de la mesa
            Text(
              widget.nombreMesa,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Recuadro con botón
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Acceder a la carta',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _abrirCarta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BA238),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver carta',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Precio total
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4025),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
