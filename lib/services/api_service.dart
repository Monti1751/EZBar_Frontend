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
}