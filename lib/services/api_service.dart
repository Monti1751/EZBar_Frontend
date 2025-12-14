import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Health check para verificar si el servidor está activo
  Future<bool> verificarConexion() async {
    try {
      print('🔍 Verificando conexión a: http://localhost:3000');
      final response = await http.get(Uri.parse('http://localhost:3000'));
      print('✅ Servidor respondió con status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('❌ No hay conexión: $e');
      return false;
    }
  }

  // Obtener todas las mesas
  Future<List<dynamic>> obtenerMesas() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.mesas));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar mesas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las zonas
  Future<List<dynamic>> obtenerZonas() async {
    try {
      print('🔌 Intentando conectar a: ${ApiConfig.zonas}');
      final response = await http.get(Uri.parse(ApiConfig.zonas));
      print('📨 Respuesta recibida: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las categorías
  Future<List<dynamic>> obtenerCategorias() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.categorias));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.categorias),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombre, 'descripcion': ''}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Error crear categoria: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error conexion: $e');
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.categorias}/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Obtener todos los productos
  Future<List<dynamic>> obtenerProductos() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.productos));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> data) async {
    // data debe incluir 'nombre', 'precio', 'categoria': {'categoria_id': ...}
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.productos),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Error crear producto: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error conexion: $e');
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.productos}/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Guardar todas las mesas de una zona
  Future<Map<String, dynamic>> guardarMesasDeZona(
    String nombreZona,
    List<Map<String, dynamic>> mesas,
  ) async {
    try {
      // Codificar correctamente el nombre de la zona en la URL
      final encodedZona = Uri.encodeComponent(nombreZona);
      final response = await http.post(
        Uri.parse('${ApiConfig.zonas}/$encodedZona/mesas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mesas': mesas}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al guardar mesas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Guardar una mesa individual
  Future<Map<String, dynamic>> guardarMesa(Map<String, dynamic> mesa) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.mesas),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mesa),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al guardar mesa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener las mesas de una zona específica
  Future<List<dynamic>> obtenerMesasPorZona(String nombreZona) async {
    try {
      print('🔍 Intentando obtener mesas para zona: $nombreZona');

      // Usar Uri.http para codificar correctamente los parámetros
      final url = Uri.parse(
        ApiConfig.mesas,
      ).replace(queryParameters: {'ubicacion': nombreZona});

      print('📍 URL generada: $url');
      final response = await http.get(url);

      print('📨 Respuesta recibida: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Si el backend devuelve {mesas: [...]} en lugar de [...]
        if (data is Map && data.containsKey('mesas')) {
          return data['mesas'];
        }
        return data;
      } else {
        throw Exception(
          'Error al cargar mesas de la zona $nombreZona: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error de conexión al cargar mesas por zona: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de una zona
  Future<Map<String, dynamic>> obtenerEstadisticasZona(String ubicacion) async {
    try {
      final encodedUbicacion = Uri.encodeComponent(ubicacion);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/zonas/$encodedUbicacion/stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estadísticas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar estado de mesa
  Future<Map<String, dynamic>> actualizarMesa(
    int mesaId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.mesas}/$mesaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar mesa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear pedido
  Future<Map<String, dynamic>> crearPedido(Map<String, dynamic> pedido) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.pedidos),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedido),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear mesa
  Future<Map<String, dynamic>> crearMesa(Map<String, dynamic> datos) async {
    try {
      print('📤 Creando mesa: ${json.encode(datos)}');
      final response = await http.post(
        Uri.parse(ApiConfig.mesas),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      print('📨 Respuesta: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al crear mesa: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error al crear mesa: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar mesa
  Future<bool> eliminarMesa(int mesaId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.mesas}/$mesaId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear zona
  Future<Map<String, dynamic>> crearZona(Map<String, dynamic> zona) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.zonas),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(zona),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear zona: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar zona
  Future<bool> eliminarZona(String ubicacion) async {
    try {
      final encodedUbicacion = Uri.encodeComponent(ubicacion);
      final response = await http.delete(
        Uri.parse('${ApiConfig.zonas}/$encodedUbicacion'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener pedido activo de una mesa
  Future<Map<String, dynamic>?> obtenerPedidoActivoMesa(int mesaId) async {
    try {
      // Obtenemos todos los pedidos y filtramos en el cliente (temporal)
      final response = await http.get(Uri.parse(ApiConfig.pedidos));

      if (response.statusCode == 200) {
        List<dynamic> pedidos = json.decode(response.body);

        // Buscar pedido de esta mesa que no esté pagado ni cancelado
        try {
          return pedidos.firstWhere((p) {
            // Verificar si 'mesa' es objeto o ID
            int? pMesaId;
            if (p['mesa'] != null) {
              if (p['mesa'] is int) {
                pMesaId = p['mesa'];
              } else if (p['mesa'] is Map) {
                pMesaId = p['mesa']['mesa_id'];
              }
            } else if (p['mesa_id'] != null) {
              pMesaId = p['mesa_id'];
            }

            if (pMesaId != mesaId) return false;

            String estado = p['estado'].toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelado';
          });
        } catch (e) {
          // Si no se encuentra ningun elemento firstWhere lanza excepcion
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo pedido activo: $e');
      return null;
    }
  }

  Future<List<dynamic>> obtenerDetallesPedido(int pedidoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.pedidos}/$pedidoId/detalles'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error obteniendo detalles: $e");
      return [];
    }
  }

  // Agregar producto a mesa (crea pedido si es necesario)
  Future<Map<String, dynamic>> agregarProductoAMesa(
    int mesaId,
    int productoId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.pedidos}/mesa/$mesaId/agregar-producto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'productoId': productoId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al agregar producto: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
