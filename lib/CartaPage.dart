import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'plato.dart';
import 'visual_settings_provider.dart';
import 'settings_menu.dart';
import 'services/api_service.dart';

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF4A4025)),
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4A4025), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7BA238), width: 2.2),
    ),
  );
}

/// Modelo de Sección
class Seccion {
  String nombre;
  bool isOpen = false;
  List<Plato> platos = [];
  Seccion({required this.nombre});
}

/// Pantalla Carta
class CartaPage extends StatefulWidget {
  /// Callback opcional para integrar el botón "+" con la cuenta
  final void Function(Plato)? onAddToCuenta;

  const CartaPage({super.key, this.onAddToCuenta});

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _seccionController = TextEditingController();
  final TextEditingController _platoController = TextEditingController();
  final ApiService _apiService = ApiService();

  late Future<List<Seccion>> _seccionesFuture;

  @override
  void initState() {
    super.initState();
    _seccionesFuture = _cargarDatos();
  }

  // Carga inicial de datos combinados (Categorías + Productos)
  Future<List<Seccion>> _cargarDatos() async {
    try {
      final categorias = await _apiService.obtenerCategorias();
      final productos = await _apiService.obtenerProductos();

      List<Seccion> seccionesLista = [];

      for (var cat in categorias) {
        Seccion nuevaSeccion = Seccion(nombre: cat['nombre']);

        // Filtrar productos de esta categoría
        var productosCategoria = productos.where((p) {
          // El backend Spring Boot devuelve 'categoria' como objeto anidado
          if (p['categoria'] != null && p['categoria'] is Map) {
            return p['categoria']['categoria_id'] == cat['categoria_id'];
          }
          // Fallback por si acaso devolviera solo ID
          return p['categoria_id'] == cat['categoria_id'];
        }).toList();

        for (var prod in productosCategoria) {
          // Parsear ingredientes, extras, alérgenos si vinieran como string separado por comas o json (según tu BD)
          // Asumiremos listas vacías por simplicidad inicial, o parsing básico
          nuevaSeccion.platos.add(
            Plato(
              id: prod['producto_id'], // Necesitarás añadir ID al modelo Plato
              nombre: prod['nombre'],
              precio: (prod['precio'] as num).toDouble(),
              // imagen: ... (manejo de URL vs File local pendiente)
            ),
          );
        }
        seccionesLista.add(nuevaSeccion);
      }
      return seccionesLista;
    } catch (e) {
      print('Error cargando carta: $e');
      return []; // Retorna lista vacía en error para no romper UI
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(
      context,
      listen: false,
    );
    return BoxDecoration(
      color: settings.darkMode ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black26),
    );
  }

  @override
  void dispose() {
    _seccionController.dispose();
    _platoController.dispose();
    super.dispose();
  }

  void _addPlatoToCuenta(Plato plato) {
    if (widget.onAddToCuenta != null) {
      widget.onAddToCuenta!(plato);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Añadido a la cuenta: ${plato.nombre}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context);

    final Color fondo = settings.darkMode
        ? Colors.black
        : const Color(0xFFECF0D5);
    final Color barraSuperior = settings.colorBlindMode
        ? Colors.blue
        : const Color(0xFF7BA238);
    final Color textoGeneral = settings.darkMode ? Colors.white : Colors.black;
    final double fontSize = settings.currentFontSize;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SettingsMenu(),
      backgroundColor: fondo,
      body: Column(
        children: [
          // Barra superior
          Container(
            height: 55,
            color: barraSuperior,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: textoGeneral, size: 28),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: loginInputDecoration("Buscar...", Icons.search),
              style: TextStyle(color: textoGeneral, fontSize: fontSize),
            ),
          ),

          // Lista de secciones (FutureBuilder)
          Expanded(
            child: FutureBuilder<List<Seccion>>(
              future: _seccionesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error al cargar la carta: ${snapshot.error}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No hay productos disponibles.",
                      style: TextStyle(color: textoGeneral),
                    ),
                  );
                }

                final secciones = snapshot.data!;

                return ListView(
                  children: [
                    for (var seccion in secciones)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: barraSuperior,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                seccion.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  color: textoGeneral,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Eliminado botón borrar sección porque viene de API
                                  Icon(
                                    seccion.isOpen
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: textoGeneral,
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(
                                  () => seccion.isOpen = !seccion.isOpen,
                                );
                              },
                            ),

                            if (seccion.isOpen)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  decoration: _cardDecoration(context),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      // Eliminada opción rápida de crear plato localmente
                                      const SizedBox(height: 10),

                                      // Lista de platos
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            for (var plato in seccion.platos)
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 4,
                                                    ),
                                                decoration: _cardDecoration(
                                                  context,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            PlatoEditorPage(
                                                              plato: plato,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        // Imagen + nombre
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              /* Manejo de imagen pendiente
                                                              if (plato.imagen != null) ...
                                                                
                                                              else */
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .grey[300],
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Colors
                                                                        .black12,
                                                                  ),
                                                                ),
                                                                child: const Icon(
                                                                  Icons.image,
                                                                  color: Colors
                                                                      .black26,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  plato.nombre,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        fontSize,
                                                                    color:
                                                                        textoGeneral,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${plato.precio.toStringAsFixed(2)} €",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      fontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textoGeneral,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        // Acciones
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .add_circle,
                                                                color:
                                                                    barraSuperior,
                                                              ),
                                                              tooltip:
                                                                  "Añadir a la cuenta",
                                                              onPressed: () =>
                                                                  _addPlatoToCuenta(
                                                                    plato,
                                                                  ),
                                                            ),
                                                            // Eliminado botón borrar plato
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Eliminado botón agregar sección
        ],
      ),
    );
  }
}
