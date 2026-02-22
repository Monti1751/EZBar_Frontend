import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/mesa.dart';
import '../models/zona.dart';
import '../models/plato.dart';
import '../models/categoria.dart';
import '../models/pedido.dart';

/// Servicio híbrido que usa API cuando hay conexión y SQLite cuando no la hay
class HybridDataService {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  // ==================== MÉTODOS PARA MESAS ====================

  Future<List<dynamic>> obtenerMesas() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        try {
          // Intentar obtener desde API
          final mesas = await _apiService.obtenerMesas();
          
          // Guardar en SQLite solo si no es Web
          if (!kIsWeb) {
            for (var mesaJson in mesas) {
              final mesa = Mesa.fromJson(mesaJson as Map<String, dynamic>);
              await _dbService.insertMesa(mesa);
            }
          }
          
          return mesas;
        } catch (e) {
          // Si falla la API, intentar con datos locales (solo si no es Web)
          if (!kIsWeb) {
            final mesasLocal = await _dbService.getMesas();
            return mesasLocal.map((m) => m.toJson()).toList();
          }
          rethrow;
        }
      } else {
        // Sin conexión - usar SQLite (solo si no es Web)
        if (!kIsWeb) {
          final mesasLocal = await _dbService.getMesas();
          return mesasLocal.map((m) => m.toJson()).toList();
        }
        return [];
      }
    } catch (e) {
      if (!kIsWeb) {
        final mesasLocal = await _dbService.getMesas();
        return mesasLocal.map((m) => m.toJson()).toList();
      }
      return [];
    }
  }

  Future<List<dynamic>> obtenerMesasPorZona(String nombreZona) async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        try {
          final mesas = await _apiService.obtenerMesasPorZona(nombreZona);
          
          // Guardar en SQLite solo si no es Web
          if (!kIsWeb) {
            for (var mesaJson in mesas) {
              final mesa = Mesa.fromJson(mesaJson as Map<String, dynamic>);
              await _dbService.insertMesa(mesa);
            }
          }
          
          return mesas;
        } catch (e) {
          if (!kIsWeb) {
            final mesasLocal = await _dbService.getMesasPorZona(nombreZona);
            return mesasLocal.map((m) => m.toJson()).toList();
          }
          return [];
        }
      } else {
        if (!kIsWeb) {
          final mesasLocal = await _dbService.getMesasPorZona(nombreZona);
          return mesasLocal.map((m) => m.toJson()).toList();
        }
        return [];
      }
    } catch (e) {
      if (!kIsWeb) {
        final mesasLocal = await _dbService.getMesasPorZona(nombreZona);
        return mesasLocal.map((m) => m.toJson()).toList();
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> crearMesa(Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearMesa(datos);
        final mesa = Mesa.fromJson(resultado);
        if (!kIsWeb) {
          await _dbService.insertMesa(mesa);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: guardar localmente con estado pendiente (solo si no es Web)
      if (kIsWeb) {
        // En Web sin conexión no podemos guardar localmente en SQL
        // Podríamos usar LocalStorage/SharedPreferences si fuera necesario, 
        // pero por ahora lanzamos error o devolvemos el objeto sin persistir
        return datos; 
      }
      if (!kIsWeb) {
        final mesa = Mesa.fromJson(datos);
        mesa.syncStatus = 'pendiente';
        mesa.localId = DateTime.now().millisecondsSinceEpoch.toString();

        await _dbService.insertMesa(mesa);
        await _dbService.addToSyncQueue(
            'CREATE', 'mesas', json.decode(json.encode(datos)));

        return mesa.toJson();
      }
      return datos;
    }
  }

  Future<Map<String, dynamic>> actualizarMesa(
      int mesaId, Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.actualizarMesa(mesaId, datos);
        final mesa = Mesa.fromJson(resultado);
        if (!kIsWeb) {
          await _dbService.updateMesa(mesa);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: actualizar localmente
      if (kIsWeb) return datos;
      if (!kIsWeb) {
        datos['sync_status'] = 'pendiente';
        final mesa = Mesa.fromJson(datos);
        await _dbService.updateMesa(mesa);
        await _dbService.addToSyncQueue(
            'UPDATE', 'mesas', json.decode(json.encode(datos)));

        return mesa.toJson();
      }
      return datos;
    }
  }

  Future<bool> eliminarMesa(int mesaId) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarMesa(mesaId);
        if (!kIsWeb) {
          await _dbService.deleteMesa(mesaId.toString());
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: marcar para eliminar
      if (kIsWeb) return true;
      if (!kIsWeb) {
        await _dbService.deleteMesa(mesaId.toString());
        await _dbService.addToSyncQueue('DELETE', 'mesas', {'id': mesaId});
      }
      return true;
    }
  }

  // ==================== MÉTODOS PARA ZONAS ====================

  Future<List<dynamic>> obtenerZonas() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        try {
          final zonas = await _apiService.obtenerZonas();
          
          // Guardar en SQLite solo si no es Web
          if (!kIsWeb) {
            for (var zonaJson in zonas) {
              final zona = Zona.fromJson(zonaJson as Map<String, dynamic>);
              await _dbService.insertZona(zona);
            }
          }
          
          return zonas;
        } catch (e) {
          // Si falla la API, intentar con datos locales (solo si no es Web)
          if (!kIsWeb) {
            final zonasLocal = await _dbService.getZonas();
            return zonasLocal.map((z) => z.toJson()).toList();
          }
          rethrow;
        }
      } else {
        // Sin conexión - usar SQLite (solo si no es Web)
        if (!kIsWeb) {
          final zonasLocal = await _dbService.getZonas();
          return zonasLocal.map((z) => z.toJson()).toList();
        }
        return [];
      }
    } catch (e) {
      if (!kIsWeb) {
        final zonasLocal = await _dbService.getZonas();
        return zonasLocal.map((z) => z.toJson()).toList();
      }
      return [];
    }
  }

  // ==================== MÉTODOS PARA PRODUCTOS ====================

  Future<List<dynamic>> obtenerProductos() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        debugPrint("📡 DIAGNOSTICO: Modo ONLINE. Intentando descargar productos del API...");
        try {
          final productos = await _apiService.obtenerProductos();
          debugPrint("📡 DIAGNOSTICO: API retornó ${productos.length} productos.");
          
          if (!kIsWeb) {
            debugPrint("📡 DIAGNOSTICO: Limpiando productos locales y guardando nuevos de API...");
            // Opcional: podrías hacer un clearAll o un delete selectivo. 
            // Para asegurar consistencia total con la API:
            await _dbService.clearProductos(); 
            
            for (var productoJson in productos) {
              final map = Map<String, dynamic>.from(productoJson as Map);
              if (map['categoria_id'] == null && map['categoria'] != null) {
                map['categoria_id'] = map['categoria']['categoria_id'] ?? map['categoria']['id'];
              }
              final producto = Plato.fromMap(map);
              await _dbService.insertProducto(producto);
            }
          }
          return productos;
        } catch (e) {
          debugPrint("📡 DIAGNOSTICO: Fallo en API o mapeo: $e");
          throw Exception("Fallo en API productos: $e");
        }
      } else {
        debugPrint("📡 DIAGNOSTICO: Modo OFFLINE. Leyendo productos de base de datos local...");
        if (!kIsWeb) {
          final productosLocal = await _dbService.getProductos();
          debugPrint("📡 DIAGNOSTICO: Local retornó ${productosLocal.length} productos.");
          return productosLocal.map((p) => p.toMap()).toList();
        }
        return [];
      }
    } catch (e) {
      debugPrint("📡 DIAGNOSTICO: Catch global en obtenerProductos: $e");
      // Si el error ocurrió durante un intento de carga online, lo re-lanzamos
      // para que el usuario vea el error real en el banner.
      throw Exception("Fallo crítico en productos: $e");
    }
  }

  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearProducto(datos);
        final producto = Plato.fromMap(resultado);
        if (!kIsWeb) {
          await _dbService.insertProducto(producto);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (kIsWeb) return datos;
      if (!kIsWeb) {
        final producto = Plato.fromMap(datos);
        producto.syncStatus = 'pendiente';
        producto.localId = DateTime.now().millisecondsSinceEpoch.toString();

        await _dbService.insertProducto(producto);
        await _dbService.addToSyncQueue(
            'CREATE', 'productos', json.decode(json.encode(datos)));

        return producto.toMap();
      }
      return datos;
    }
  }

  Future<Map<String, dynamic>> actualizarProducto(
      int id, Map<String, dynamic> datos) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.actualizarProducto(id, datos);
        final producto = Plato.fromMap(resultado);
        if (!kIsWeb) {
          await _dbService.updateProducto(producto);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (kIsWeb) return datos;
      if (!kIsWeb) {
        datos['sync_status'] = 'pendiente';
        final producto = Plato.fromMap(datos);
        await _dbService.updateProducto(producto);
        await _dbService.addToSyncQueue(
            'UPDATE', 'productos', json.decode(json.encode(datos)));

        return producto.toMap();
      }
      return datos;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarProducto(id);
        if (!kIsWeb) {
          await _dbService.deleteProducto(id);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (kIsWeb) return true;
      if (!kIsWeb) {
        await _dbService.deleteProducto(id);
        await _dbService.addToSyncQueue('DELETE', 'productos', {'id': id});
      }
      return true;
    }
  }

  // ==================== MÉTODOS PARA CATEGORÍAS ====================

  Future<List<dynamic>> obtenerCategorias() async {
    try {
      final isOnline = await _apiService.verificarConexion();

      if (isOnline) {
        try {
          final categorias = await _apiService.obtenerCategorias();
          
          // Guardar en SQLite solo si no es Web
          if (!kIsWeb) {
            debugPrint("📡 DIAGNOSTICO: Limpiando categorías locales y sincronizando con API...");
            await _dbService.clearCategorias();
            for (var categoriaJson in categorias) {
              final categoria = Categoria.fromJson(categoriaJson as Map<String, dynamic>);
              await _dbService.insertCategoria(categoria);
            }
          }
          
          return categorias;
        } catch (e) {
          // Si falla la API, intentar con datos locales (solo si no es Web)
          if (!kIsWeb) {
            final categoriasLocal = await _dbService.getCategorias();
            return categoriasLocal.map((c) => c.toJson()).toList();
          }
          rethrow;
        }
      } else {
        // Sin conexión - usar SQLite (solo si no es Web)
        if (!kIsWeb) {
          final categoriasLocal = await _dbService.getCategorias();
          return categoriasLocal.map((c) => c.toJson()).toList();
        }
        return [];
      }
    } catch (e) {
      if (!kIsWeb) {
        final categoriasLocal = await _dbService.getCategorias();
        return categoriasLocal.map((c) => c.toJson()).toList();
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.crearCategoria(nombre);
        final categoria = Categoria.fromJson(resultado);
        if (!kIsWeb) {
          await _dbService.insertCategoria(categoria);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (kIsWeb) return {'nombre': nombre};
      if (!kIsWeb) {
        final categoria = Categoria(nombre: nombre, syncStatus: 'pendiente');
        await _dbService.insertCategoria(categoria);
        await _dbService
            .addToSyncQueue('CREATE', 'categorias', {'nombre': nombre});

        return categoria.toJson();
      }
      return {'nombre': nombre};
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    final isOnline = await _apiService.verificarConexion();

    if (isOnline) {
      try {
        final resultado = await _apiService.eliminarCategoria(id);
        if (!kIsWeb) {
          await _dbService.deleteCategoria(id);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (kIsWeb) return true;
      if (!kIsWeb) {
        await _dbService.deleteCategoria(id);
        await _dbService.addToSyncQueue('DELETE', 'categorias', {'id': id});
      }
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
  Future<Pedido?> obtenerPedidoActivoMesa(int mesaId) async {
    print('🔍 DIAGNÓSTICO: Buscando pedido activo para mesa $mesaId...');
    try {
      if (kIsWeb) {
        print('🌐 DIAGNÓSTICO: Corriendo en WEB, saltando SQLite local.');
      }

      // 1. Intentar obtener de la API
      print('📡 DIAGNÓSTICO: Llamando a ApiService.obtenerPedidoActivoMesa($mesaId)');
      final apiData = await _apiService.obtenerPedidoActivoMesa(mesaId);
      
      if (apiData != null) {
        print('✅ DIAGNÓSTICO: API devolvió datos: ${json.encode(apiData)}');
        final pedido = Pedido.fromJson(apiData);
        
        // Cargar detalles también
        print('📡 DIAGNÓSTICO: Cargando detalles desde API para pedido ${pedido.id}');
        final detallesData = await _apiService.obtenerDetallesPedido(pedido.id!);
        print('✅ DIAGNÓSTICO: Detalles recibidos: ${detallesData.length} líneas');
        pedido.detalles = detallesData.map((d) => DetallePedido.fromJson(d)).toList();
        
        return pedido;
      }
      
      print('⚠️ DIAGNÓSTICO: API devolvió null para mesa $mesaId');

      if (kIsWeb) return null;

      // 2. Si no hay API o devuelve null, intentar de la DB local
      print('🏠 DIAGNÓSTICO: Buscando en base de datos LOCAL (SQLite)...');
      final localPedido = await _dbService.getPedidoActivoMesa(mesaId);
      
      if (localPedido != null) {
        print('✅ DIAGNÓSTICO: SQLite local devolvió pedido ID ${localPedido.id}');
      } else {
        print('❌ DIAGNÓSTICO: Tampoco se encontró pedido en SQLite local');
      }
      
      return localPedido;
    } catch (e) {
      print('💥 DIAGNÓSTICO: Error en obtenerPedidoActivoMesa: $e');
      return null;
    }
  }

  Future<List<dynamic>> obtenerDetallesPedido(int pedidoId) async {
    print('🔍 DIAGNÓSTICO: Buscando detalles para pedido $pedidoId...');
    try {
      final isOnline = await _apiService.verificarConexion();
      
      if (isOnline) {
        print('📡 DIAGNÓSTICO: Pedido $pedidoId ONLINE. Llamando a ApiService.obtenerDetallesPedido...');
        final detalles = await _apiService.obtenerDetallesPedido(pedidoId);
        print('✅ DIAGNÓSTICO: Detalles recibidos de API: ${detalles.length} líneas');
        
        if (!kIsWeb) {
          print('🏠 DIAGNÓSTICO: Sincronizando detalles en SQLite local...');
          for (var detalleJson in detalles) {
            final detalle =
                DetallePedido.fromJson(detalleJson as Map<String, dynamic>);
            await _dbService.insertDetallePedido(detalle);
          }
        }
        
        return detalles;
      } else {
        if (!kIsWeb) {
          print('🏠 DIAGNÓSTICO: Modo OFFLINE. Buscando detalles en SQLite local para pedido $pedidoId...');
          final detallesLocal = await _dbService.getDetallesPedido(pedidoId);
          print('✅ DIAGNÓSTICO: SQLite local devolvió ${detallesLocal.length} líneas');
          return detallesLocal.map((d) => d.toJson()).toList();
        }
        return [];
      }
    } catch (e) {
      print('💥 DIAGNÓSTICO: Error en obtenerDetallesPedido ($pedidoId): $e');
      if (!kIsWeb) {
        print('🏠 DIAGNÓSTICO: Error detectado, reintentando con SQLite local...');
        final detallesLocal = await _dbService.getDetallesPedido(pedidoId);
        return detallesLocal.map((d) => d.toJson()).toList();
      }
      return [];
    }
  }

  Future<void> agregarProductoAMesa(int mesaId, int productoId) async {
    final isOnline = await _apiService.verificarConexion();
    
    if (isOnline) {
      try {
        await _apiService.agregarProductoAMesa(mesaId, productoId);
      } catch (e) {
        rethrow;
      }
    } else {
      // Sin conexión: crear localmente (solo si no es Web)
      if (!kIsWeb) {
        final pedido = await _dbService.getPedidoActivoMesa(mesaId);

        if (pedido != null) {
          // Si el pedido existe, agregar un detalle
          final producto = (await _dbService.getProductos()).firstWhere(
              (p) => p.id == productoId,
              orElse: () => Plato(
                  id: productoId,
                  nombre: 'Producto',
                  precio: 0.0,
                  ingredientes: [],
                  extras: [],
                  alergenos: [],
                  imagenUrl: '',
                  imagenBlob: '',
                  syncStatus: 'pendiente'));

          final detalle = DetallePedido(
            pedidoId: pedido.id,
            productoId: productoId,
            nombreProducto: producto.nombre,
            cantidad: 1,
            precioUnitario: producto.precio,
            syncStatus: 'pendiente',
          );

          await _dbService.insertDetallePedido(detalle);
          await _dbService.addToSyncQueue(
              'CREATE', 'detalles_pedido', detalle.toJson());
        }
      }
    }
  }

  Future<void> eliminarDetallePedido(int detalleId) async {
    final isOnline = await _apiService.verificarConexion();
    
    if (isOnline) {
      try {
        await _apiService.eliminarDetallePedido(detalleId);
      } catch (e) {
        rethrow;
      }
    } else {
      if (!kIsWeb) {
        await _dbService.deleteDetallePedido(detalleId);
        await _dbService.addToSyncQueue(
            'DELETE', 'detalles_pedido', {'id': detalleId});
      }
    }
  }

  Future<Map<String, dynamic>> crearPedido(Map<String, dynamic> pedido) async {
    final isOnline = await _apiService.verificarConexion();
    
    if (isOnline) {
      try {
        final resultado = await _apiService.crearPedido(pedido);
        final pedidoObj = Pedido.fromJson(resultado);
        if (!kIsWeb) {
          await _dbService.insertPedido(pedidoObj);
        }
        return resultado;
      } catch (e) {
        rethrow;
      }
    } else {
      if (!kIsWeb) {
        pedido['sync_status'] = 'pendiente';
        pedido['fecha'] = DateTime.now().toIso8601String();
        final pedidoObj = Pedido(
          mesaId: pedido['mesa_id'] as int,
          estado: pedido['estado'] as String? ?? 'activo',
          fecha: DateTime.parse(pedido['fecha'] as String),
          syncStatus: 'pendiente',
        );

        await _dbService.insertPedido(pedidoObj);
        await _dbService.addToSyncQueue('CREATE', 'pedidos', pedido);

        return pedidoObj.toJson();
      }
      return pedido;
    }
  }

  Future<void> finalizarPedido(int? pedidoId) async {
    if (pedidoId == null) return;
    
    final isOnline = await _apiService.verificarConexion();
    
    if (isOnline) {
      try {
        await _apiService.finalizarPedido(pedidoId);
      } catch (e) {
        rethrow;
      }
    } else {
      if (!kIsWeb) {
        final pedido = (await _dbService.getPedidos()).firstWhere(
            (p) => p.id == pedidoId,
            orElse: () => Pedido(
                mesaId: 0, estado: 'activo', fecha: DateTime.now()));

        if (pedido.id != null) {
          pedido.estado = 'pagado';
          pedido.syncStatus = 'pendiente';
          await _dbService.updatePedido(pedido);
          await _dbService.addToSyncQueue(
              'UPDATE', 'pedidos', {'id': pedidoId, 'estado': 'pagado'});
        }
      }
    }
  }

  // Delegar otros métodos directamente al API service

  Future<Map<String, dynamic>> crearZona(Map<String, dynamic> zona) async {
    return await _apiService.crearZona(zona);
  }

  Future<bool> eliminarZona(String ubicacion) async {
    return await _apiService.eliminarZona(ubicacion);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    return await _apiService.login(username, password);
  }

  Future<Map<String, dynamic>?> verificarToken() async {
    return await _apiService.verificarToken();
  }
}
