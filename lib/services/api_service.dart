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
  
 
Future<List<dynamic>> obtenerZonas() async {
  try {
    print('🔌 Intentando conectar a: ${ApiConfig.zonas}');
    final response = await http.get(Uri.parse(ApiConfig.zonas));
    print('📨 Respuesta recibida: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body); // ✅ Devuelve List<dynamic>
    } else {
      throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
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
      print('🔍 Intentando obtener mesas para zona: $nombreZona en $url');
      final response = await http.get(url);
      print('📨 Respuesta recibida para mesas: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Asegúrate de que el body es una lista JSON, lo cual es lo habitual para colecciones
        return json.decode(response.body); 
      } else {
        throw Exception('Error al cargar mesas de la zona $nombreZona: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión al cargar mesas por zona: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de una zona
  Future<Map<String, dynamic>> obtenerEstadisticasZona(String ubicacion) async {
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
        Uri.parse('${ApiConfig.baseUrl}/api/zonas/$ubicacion/stats')
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
      final response = await http.post(
        Uri.parse(ApiConfig.mesas),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.delete(
        Uri.parse('${ApiConfig.mesas}/$mesaId'),
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

  // Eliminar zona (ya no es necesario porque las zonas están en la tabla mesas)
  // Mantenerlo por compatibilidad pero podría no usarse
  Future<bool> eliminarZona(String ubicacion) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.zonas}/$ubicacion'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
