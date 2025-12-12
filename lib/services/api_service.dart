import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
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
  
  // Obtener mesas por zona
  Future<List<dynamic>> obtenerMesasPorZona(int zonaId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.mesas}/zona/$zonaId')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar mesas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Actualizar estado de mesa
  Future<Map<String, dynamic>> actualizarMesa(
    int mesaId, 
    Map<String, dynamic> datos
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
        throw Exception('Error al actualizar mesa');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Crear pedido
  Future<Map<String, dynamic>> crearPedido(
    Map<String, dynamic> pedido
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.pedidos),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedido),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear pedido');
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
      throw Exception('Error al crear mesa');
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

// Obtener todas las zonas
Future<List<dynamic>> obtenerZonas() async {
  try {
    final response = await http.get(Uri.parse(ApiConfig.zonas));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar zonas');
    }
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
        throw Exception('Error al crear zona');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar zona
  Future<bool> eliminarZona(int zonaId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.zonas}/$zonaId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}