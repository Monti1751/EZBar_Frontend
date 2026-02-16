import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_manager.dart';

class ApiService {
  final TokenManager _tokenManager = TokenManager();

  // Obtener headers con autorización
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (token != null) {
      print('📤 Header Authorization: Bearer $token');
    }
    return headers;
  }

  // Health check para verificar si el servidor está activo
  Future<bool> verificarConexion() async {
    try {
      // print('🔍 Verificando conexión a: https://euphoniously-subpatellar-chandra.ngrok-free.dev');
      final response = await http.get(
          Uri.parse('https://euphoniously-subpatellar-chandra.ngrok-free.dev'));
      // print('✅ Servidor respondió con status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      // print('❌ No hay conexión: $e');
      return false;
    }
  }

  // Obtener todas las mesas
  Future<List<dynamic>> obtenerMesas() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.mesas), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar mesas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerZonas() async {
    try {
      // print('🔌 Intentando conectar a: ${ApiConfig.zonas}');
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.zonas), headers: headers);
      // print('📨 Respuesta recibida: ${response.statusCode}');
      // print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body); // ✅ Devuelve List<dynamic>
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las categorías
  Future<List<dynamic>> obtenerCategorias() async {
    try {
      // print('🔌 Intentando conectar a: ${ApiConfig.categorias}');
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.categorias), headers: headers);
      // print('📨 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los productos
  Future<List<dynamic>> obtenerProductos() async {
    try {
      // print('🔌 Intentando conectar a: ${ApiConfig.productos}');
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.productos), headers: headers);
      // print('📨 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear categoría
  Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.categorias),
        headers: headers,
        body: json.encode({'nombre': nombre}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar categoría
  Future<bool> eliminarCategoria(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.categorias}/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear producto
  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> datos) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.productos),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar producto
  Future<Map<String, dynamic>> actualizarProducto(int id, Map<String, dynamic> datos) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.productos}/$id'),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar producto
  Future<bool> eliminarProducto(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.productos}/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener las mesas de una zona específica
  Future<List<dynamic>> obtenerMesasPorZona(String nombreZona) async {
    // Asumiendo que tu backend tiene un endpoint para filtrar mesas por ubicación (zona)
    // Usaremos la ruta 'ApiConfig.mesas?ubicacion=nombreZona' o similar.
    // Si tu API usa una ruta tipo /mesas/zona/:nombreZona, ajústalo.
    final url = Uri.parse('${ApiConfig.mesas}?ubicacion=$nombreZona');

    try {
      // print('🔍 Intentando obtener mesas para zona: $nombreZona en $url');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      // print('📨 Respuesta recibida para mesas: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Asegúrate de que el body es una lista JSON, lo cual es lo habitual para colecciones
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al cargar mesas de la zona $nombreZona: ${response.statusCode}',
        );
      }
    } catch (e) {
      // print('❌ Error de conexión al cargar mesas por zona: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de una zona
  Future<Map<String, dynamic>> obtenerEstadisticasZona(String ubicacion) async {
    try {
      // print('🔍 Intentando obtener mesas para zona: $ubicacion');

      // Usar Uri.http para codificar correctamente los parámetros
      final url = Uri.parse(
        ApiConfig.mesas,
      ).replace(queryParameters: {'ubicacion': ubicacion});

      // print('📍 URL generada: $url');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      // print('📨 Respuesta recibida: ${response.statusCode}');
      // print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Si el backend devuelve {mesas: [...]} en lugar de [...]
        if (data is Map && data.containsKey('mesas')) {
          return data['mesas'];
        }
        return data;
      } else {
        throw Exception(
          'Error al cargar mesas de la zona $ubicacion: ${response.statusCode}',
        );
      }
    } catch (e) {
      // print('❌ Error de conexión al cargar mesas por zona: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de una zona
  Future<Map<String, dynamic>> obtenerDatosEstadisticosZona(
    String ubicacion,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/zonas/$ubicacion/stats'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.mesas}/$mesaId'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.pedidos),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.mesas),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear mesa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar mesa
  Future<bool> eliminarMesa(int mesaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.mesas}/$mesaId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear zona (ya no es necesario porque las zonas están en la tabla mesas)
  // Mantenerlo por compatibilidad pero podría no usarse
  Future<Map<String, dynamic>> crearZona(Map<String, dynamic> zona) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.zonas),
        headers: headers,
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

  // Eliminar zona (ya no es necesario porque las zonas están en la tabla mesas)
  // Mantenerlo por compatibilidad pero podría no usarse
  Future<bool> eliminarZona(String ubicacion) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.zonas}/$ubicacion'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- MÉTODOS DE PEDIDOS Y DETALLES (Agregados para cuenta.dart) ---

  Future<Map<String, dynamic>?> obtenerPedidoActivoMesa(int mesaId) async {
    try {
      // Endpoint aproximado: ajusta según tu backend real
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.pedidos}/mesa/$mesaId/activo'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      // print('Error al obtener pedido activo: $e');
      return null;
    }
  }

  Future<List<dynamic>> obtenerDetallesPedido(int pedidoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.pedidos}/$pedidoId/detalles'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      // print('Error al obtener detalles: $e');
      return [];
    }
  }

  Future<void> agregarProductoAMesa(int mesaId, int productoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.pedidos}/mesa/$mesaId/agregar-producto'),
        headers: headers,
        body: json.encode({'productoId': productoId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<void> eliminarDetallePedido(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.pedidos}/detalles/$detalleId'),
        headers: headers,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar detalle: $e');
    }
  }

  Future<void> finalizarPedido(int pedidoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.pedidos}/$pedidoId/finalizar'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error al finalizar pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- Login ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
      final body = json.encode({'username': username, 'password': password});
      // print('🔐 POST $uri');
      // print('📤 Body: $body');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // print('📥 Status: ${response.statusCode}');
      // print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final serverMsg = response.body.isNotEmpty
            ? response.body
            : 'Credenciales incorrectas';
        throw Exception('Credenciales incorrectas: $serverMsg');
      } else if (response.statusCode == 403) {
        final serverMsg =
            response.body.isNotEmpty ? response.body : 'Usuario desactivado';
        throw Exception('Usuario desactivado: $serverMsg');
      } else {
        throw Exception(
          'Error en el servidor: ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('$e'); // Propagar el mensaje de error directamente
    }
  }
}
