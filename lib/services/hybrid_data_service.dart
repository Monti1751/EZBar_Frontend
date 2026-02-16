import 'dart:convert';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/mesa.dart';
import '../models/zona.dart';
import '../models/plato.dart';
import '../models/categoria.dart';

/// Servicio híbrido que usa API cuando hay conexión y SQLite cuando no la hay
class HybridDataService {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  // ==================== MÉTODOS PARA MESAS ====================

  Future<List<dynamic>> obtenerMesas() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        // Intentar obtener desde API
        final mesas = await _apiService.obtenerMesas();

        // Guardar en SQLite para uso offline
        for (var mesaJson in mesas) {
          final mesa = Mesa.fromJson(mesaJson as Map<String, dynamic>);
          await _dbService.insertMesa(mesa);
        }

        return mesas;
      } else {
        // Sin conexión, usar datos locales
        final mesasLocal = await _dbService.getMesas();
        return mesasLocal.map((m) => m.toJson()).toList();
      }
    } catch (e) {
      // Si falla la API, intentar con datos locales
      final mesasLocal = await _dbService.getMesas();
      return mesasLocal.map((m) => m.toJson()).toList();
    }
  }

  Future<List<dynamic>> obtenerMesasPorZona(String nombreZona) async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        final mesas = await _apiService.obtenerMesasPorZona(nombreZona);

        // Guardar en SQLite
        for (var mesaJson in mesas) {
          final mesa = Mesa.fromJson(mesaJson as Map<String, dynamic>);
          await _dbService.insertMesa(mesa);
        }

        return mesas;
      } else {
        final mesasLocal = await _dbService.getMesasPorZona(nombreZona);
        return mesasLocal.map((m) => m.toJson()).toList();
      }
    } catch (e) {
      final mesasLocal = await _dbService.getMesasPorZona(nombreZona);
      return mesasLocal.map((m) => m.toJson()).toList();
    }
  }

  Future<Map<String, dynamic>> crearMesa(Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearMesa(datos);
        final mesa = Mesa.fromJson(resultado);
        await _dbService.insertMesa(mesa);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: guardar localmente con estado pendiente
      final mesa = Mesa.fromJson(datos);
      mesa.syncStatus = 'pendiente';
      mesa.localId = DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.insertMesa(mesa);
      await _dbService.addToSyncQueue(
          'CREATE', 'mesas', json.decode(json.encode(datos)));

      return mesa.toJson();
    }
  }

  Future<Map<String, dynamic>> actualizarMesa(
      int mesaId, Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.actualizarMesa(mesaId, datos);
        final mesa = Mesa.fromJson(resultado);
        await _dbService.updateMesa(mesa);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: actualizar localmente
      datos['sync_status'] = 'pendiente';
      final mesa = Mesa.fromJson(datos);
      await _dbService.updateMesa(mesa);
      await _dbService.addToSyncQueue(
          'UPDATE', 'mesas', json.decode(json.encode(datos)));

      return mesa.toJson();
    }
  }

  Future<bool> eliminarMesa(int mesaId) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarMesa(mesaId);
        await _dbService.deleteMesa(mesaId.toString());
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: marcar para eliminar
      await _dbService.deleteMesa(mesaId.toString());
      await _dbService.addToSyncQueue('DELETE', 'mesas', {'id': mesaId});
      return true;
    }
  }

  // ==================== MÉTODOS PARA ZONAS ====================

  Future<List<dynamic>> obtenerZonas() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        final zonas = await _apiService.obtenerZonas();

        for (var zonaJson in zonas) {
          final zona = Zona.fromJson(zonaJson as Map<String, dynamic>);
          await _dbService.insertZona(zona);
        }

        return zonas;
      } else {
        final zonasLocal = await _dbService.getZonas();
        return zonasLocal.map((z) => z.toJson()).toList();
      }
    } catch (e) {
      final zonasLocal = await _dbService.getZonas();
      return zonasLocal.map((z) => z.toJson()).toList();
    }
  }

  // ==================== MÉTODOS PARA PRODUCTOS ====================

  Future<List<dynamic>> obtenerProductos() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        final productos = await _apiService.obtenerProductos();

        for (var productoJson in productos) {
          final producto = Plato.fromMap(productoJson as Map<String, dynamic>);
          await _dbService.insertProducto(producto);
        }

        return productos;
      } else {
        final productosLocal = await _dbService.getProductos();
        return productosLocal.map((p) => p.toMap()).toList();
      }
    } catch (e) {
      final productosLocal = await _dbService.getProductos();
      return productosLocal.map((p) => p.toMap()).toList();
    }
  }

  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearProducto(datos);
        final producto = Plato.fromMap(resultado);
        await _dbService.insertProducto(producto);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      final producto = Plato.fromMap(datos);
      producto.syncStatus = 'pendiente';
      producto.localId = DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.insertProducto(producto);
      await _dbService.addToSyncQueue(
          'CREATE', 'productos', json.decode(json.encode(datos)));

      return producto.toMap();
    }
  }

  Future<Map<String, dynamic>> actualizarProducto(
      int id, Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.actualizarProducto(id, datos);
        final producto = Plato.fromMap(resultado);
        await _dbService.updateProducto(producto);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      datos['sync_status'] = 'pendiente';
      final producto = Plato.fromMap(datos);
      await _dbService.updateProducto(producto);
      await _dbService.addToSyncQueue(
          'UPDATE', 'productos', json.decode(json.encode(datos)));

      return producto.toMap();
    }
  }

  Future<bool> eliminarProducto(int id) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarProducto(id);
        await _dbService.deleteProducto(id);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      await _dbService.deleteProducto(id);
      await _dbService.addToSyncQueue('DELETE', 'productos', {'id': id});
      return true;
    }
  }

  // ==================== MÉTODOS PARA CATEGORÍAS ====================

  Future<List<dynamic>> obtenerCategorias() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        final categorias = await _apiService.obtenerCategorias();

        for (var categoriaJson in categorias) {
          final categoria =
              Categoria.fromJson(categoriaJson as Map<String, dynamic>);
          await _dbService.insertCategoria(categoria);
        }

        return categorias;
      } else {
        final categoriasLocal = await _dbService.getCategorias();
        return categoriasLocal.map((c) => c.toJson()).toList();
      }
    } catch (e) {
      final categoriasLocal = await _dbService.getCategorias();
      return categoriasLocal.map((c) => c.toJson()).toList();
    }
  }

  Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearCategoria(nombre);
        final categoria = Categoria.fromJson(resultado);
        await _dbService.insertCategoria(categoria);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      final categoria = Categoria(nombre: nombre, syncStatus: 'pendiente');
      await _dbService.insertCategoria(categoria);
      await _dbService
          .addToSyncQueue('CREATE', 'categorias', {'nombre': nombre});

      return categoria.toJson();
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarCategoria(id);
        await _dbService.deleteCategoria(id);
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      await _dbService.deleteCategoria(id);
      await _dbService.addToSyncQueue('DELETE', 'categorias', {'id': id});
      return true;
    }
  }

  // ==================== MÉTODOS DE UTILIDAD ====================

  Future<bool> verificarConexion() async {
    return await _apiService.verificarConexion();
  }

  // Delegar otros métodos directamente al API service
  Future<Map<String, dynamic>> obtenerEstadisticasZona(String ubicacion) async {
    return await _apiService.obtenerEstadisticasZona(ubicacion);
  }

  Future<Map<String, dynamic>> obtenerDatosEstadisticosZona(
      String ubicacion) async {
    return await _apiService.obtenerDatosEstadisticosZona(ubicacion);
  }

  Future<Map<String, dynamic>?> obtenerPedidoActivoMesa(int mesaId) async {
    return await _apiService.obtenerPedidoActivoMesa(mesaId);
  }

  Future<List<dynamic>> obtenerDetallesPedido(int pedidoId) async {
    return await _apiService.obtenerDetallesPedido(pedidoId);
  }

  Future<void> agregarProductoAMesa(int mesaId, int productoId) async {
    return await _apiService.agregarProductoAMesa(mesaId, productoId);
  }

  Future<void> eliminarDetallePedido(int detalleId) async {
    return await _apiService.eliminarDetallePedido(detalleId);
  }

  Future<Map<String, dynamic>> crearPedido(Map<String, dynamic> pedido) async {
    return await _apiService.crearPedido(pedido);
  }

  Future<Map<String, dynamic>> crearZona(Map<String, dynamic> zona) async {
    return await _apiService.crearZona(zona);
  }

  Future<bool> eliminarZona(String ubicacion) async {
    return await _apiService.eliminarZona(ubicacion);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    return await _apiService.login(username, password);
  }

  Future<void> finalizarPedido(int pedidoId) async {
    return await _apiService.finalizarPedido(pedidoId);
  }
}
