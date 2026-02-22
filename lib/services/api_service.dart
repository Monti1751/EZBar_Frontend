import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_manager.dart';
import '../config/app_constants.dart';
import 'logger_service.dart';

class ApiService {
  final TokenManager _tokenManager = TokenManager();

  // Caché de estado de conexión
  DateTime? _lastConnCheck;
  bool? _lastConnResult;
  static const Duration _connCacheDuration = Duration(seconds: 5);

  // Obtener headers con autorización
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (token != null) {
      print('📤 Header Authorization: Bearer $token');
    }
    return headers;
  }

  Future<bool> verificarConexion() async {
    // Retornar resultado cacheado si es muy reciente (2 seg) para debugging
    if (_lastConnCheck != null &&
        _lastConnResult != null &&
        DateTime.now().difference(_lastConnCheck!) < const Duration(seconds: 2)) {
      return _lastConnResult!;
    }

    try {
      final url = "${ApiConfig.baseUrl}/api/zonas";
      debugPrint("📡 DIAGNOSTICO: Verificando conexión a $url...");
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'ngrok-skip-browser-warning': 'true'},
          )
          .timeout(const Duration(seconds: 20)); // Tiempo extra para ngrok
      
      final isOk = response.statusCode == 200 || response.statusCode == 404;
      debugPrint("📡 DIAGNOSTICO: Servidor respondió. Status: ${response.statusCode}. Conexión OK: $isOk");
      
      _lastConnCheck = DateTime.now();
      _lastConnResult = isOk;
      return isOk;
    } catch (e) {
      debugPrint("📡 DIAGNOSTICO: Fallo al verificar conexión: $e");
      _lastConnCheck = DateTime.now();
      _lastConnResult = false;
      return false;
    }
  }

  // Obtener todas las mesas
  Future<List<dynamic>> obtenerMesas() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(ApiConfig.mesas), headers: headers)
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk) {
        return json.decode(response.body);
      } else {
        LoggerService.w('Error al cargar mesas: ${response.statusCode}');
        throw Exception('Error al cargar mesas: ${response.statusCode}');
      }
    } catch (e, stack) {
      LoggerService.e('Error de conexión al obtener mesas', e, stack);
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerZonas() async {
    try {
      LoggerService.d('Intentando conectar a: ${ApiConfig.zonas}');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(ApiConfig.zonas), headers: headers)
          .timeout(AppConstants.networkTimeout);
      LoggerService.i('Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == AppConstants.httpOk) {
        return json.decode(response.body); // ✅ Devuelve List<dynamic>
      } else {
        LoggerService.w('Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      LoggerService.e('Error al obtener zonas', e, stack);
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las categorías
  Future<List<dynamic>> obtenerCategorias() async {
    try {
      // print('🔌 Intentando conectar a: ${ApiConfig.categorias}');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(ApiConfig.categorias), headers: headers)
          .timeout(AppConstants.networkTimeout);
      // print('📨 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .get(Uri.parse(ApiConfig.productos), headers: headers)
          .timeout(AppConstants.networkTimeout);
      // print('📨 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .post(
            Uri.parse(ApiConfig.categorias),
            headers: headers,
            body: json.encode({'nombre': nombre}),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpCreated ||
          response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.categorias}/$id'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);
      return response.statusCode == AppConstants.httpOk ||
             response.statusCode == AppConstants.httpNoContent;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear producto
  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> datos) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.productos),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpCreated ||
          response.statusCode == AppConstants.httpOk) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar producto
  Future<Map<String, dynamic>> actualizarProducto(
      int id, Map<String, dynamic> datos) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.productos}/$id'),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.productos}/$id'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);
      return response.statusCode == AppConstants.httpOk ||
             response.statusCode == AppConstants.httpNoContent;
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
      final response = await http
          .get(url, headers: headers)
          .timeout(AppConstants.networkTimeout);
      // print('📨 Respuesta recibida para mesas: ${response.statusCode}');

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .get(url, headers: headers)
          .timeout(AppConstants.networkTimeout);

      // print('📨 Respuesta recibida: ${response.statusCode}');
      // print('📦 Body: ${response.body}');

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/zonas/$ubicacion/stats'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .put(
            Uri.parse('${ApiConfig.mesas}/$mesaId'),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .post(
            Uri.parse(ApiConfig.pedidos),
            headers: headers,
            body: json.encode(pedido),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpCreated ||
          response.statusCode == AppConstants.httpOk) {
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
      final response = await http
          .post(
            Uri.parse(ApiConfig.mesas),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk ||
          response.statusCode == AppConstants.httpCreated) {
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
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.mesas}/$mesaId'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);

      return response.statusCode == AppConstants.httpOk ||
             response.statusCode == AppConstants.httpNoContent;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear zona (ya no es necesario porque las zonas están en la tabla mesas)
  // Mantenerlo por compatibilidad pero podría no usarse
  Future<Map<String, dynamic>> crearZona(Map<String, dynamic> zona) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.zonas),
            headers: headers,
            body: json.encode(zona),
          )
          .timeout(AppConstants.networkTimeout);

      if (response.statusCode == AppConstants.httpOk ||
          response.statusCode == AppConstants.httpCreated) {
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
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.zonas}/$ubicacion'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);

      return response.statusCode == AppConstants.httpOk ||
             response.statusCode == AppConstants.httpNoContent;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- MÉTODOS DE PEDIDOS Y DETALLES (Agregados para cuenta.dart) ---

  Future<Map<String, dynamic>?> obtenerPedidoActivoMesa(int mesaId) async {
    print('📡 API_SERVICE: obtenerPedidoActivoMesa($mesaId) INICIO');
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.pedidos}/mesa/$mesaId/activo';
      print('📡 API_SERVICE: GET $url');
      
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(AppConstants.networkTimeout);
          
      print('📡 API_SERVICE: Status: ${response.statusCode}');
      
      if (response.statusCode == AppConstants.httpOk) {
        print('📡 API_SERVICE: Body: ${response.body}');
        return json.decode(response.body);
      }
      print('📡 API_SERVICE: No ok. Body: ${response.body}');
      return null;
    } catch (e) {
      print('📡 API_SERVICE: ERROR: $e');
      return null;
    }
  }

  Future<List<dynamic>> obtenerDetallesPedido(int pedidoId) async {
    print('📡 API_SERVICE: obtenerDetallesPedido($pedidoId) INICIO');
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.pedidos}/$pedidoId/detalles';
      print('📡 API_SERVICE: GET $url');
      
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(AppConstants.networkTimeout);
          
      print('📡 API_SERVICE: Status: ${response.statusCode}');
      
      if (response.statusCode == AppConstants.httpOk) {
        print('📡 API_SERVICE: Body: ${response.body}');
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('📡 API_SERVICE: ERROR: $e');
      return [];
    }
  }

  Future<void> agregarProductoAMesa(int mesaId, int productoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.pedidos}/mesa/$mesaId/agregar-producto'),
            headers: headers,
            body: json.encode({'productoId': productoId}),
          )
          .timeout(AppConstants.networkTimeout);
      if (response.statusCode != AppConstants.httpOk &&
          response.statusCode != AppConstants.httpCreated) {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<void> eliminarDetallePedido(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.pedidos}/detalles/$detalleId'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);
      if (response.statusCode != AppConstants.httpOk &&
          response.statusCode != AppConstants.httpNoContent) {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar detalle: $e');
    }
  }

  Future<void> finalizarPedido(int pedidoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.pedidos}/$pedidoId/finalizar'),
            headers: headers,
          )
          .timeout(AppConstants.networkTimeout);
      if (response.statusCode != AppConstants.httpOk) {
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
      LoggerService.d('Intentando login en $uri');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true'
            },
            body: body,
          )
          .timeout(AppConstants.networkTimeout);

      LoggerService.i('Status de login: ${response.statusCode}');

      if (response.statusCode == AppConstants.httpOk) {
        LoggerService.i('Login exitoso para usuario: $username');
        return json.decode(response.body);
      } else if (response.statusCode == AppConstants.httpUnauthorized) {
        LoggerService.w('Credenciales incorrectas para: $username');
        final serverMsg = response.body.isNotEmpty
            ? response.body
            : 'Credenciales incorrectas';
        throw Exception('Credenciales incorrectas: $serverMsg');
      } else if (response.statusCode == AppConstants.httpForbidden) {
        LoggerService.w('Usuario desactivado: $username');
        final serverMsg =
            response.body.isNotEmpty ? response.body : 'Usuario desactivado';
        throw Exception('Usuario desactivado: $serverMsg');
      } else {
        LoggerService.e(
            'Error de servidor en login (${response.statusCode}): ${response.body}');
        throw Exception(
          'Error en el servidor: ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, stack) {
      LoggerService.e('Excepción durante proceso de login', e, stack);
      throw Exception('$e'); // Propagar el mensaje de error directamente
    }
  }
}
