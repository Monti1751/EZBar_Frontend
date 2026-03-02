import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/mesa.dart';
import '../models/zona.dart';
import '../models/plato.dart';
import '../models/categoria.dart';

class SyncService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  bool _isOnline = false;
  bool _isSyncing = false;
  int _pendingOperations = 0;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingOperations => _pendingOperations;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService() {
    _initSync();
  }

  void _initSync() {
    // Verificar conexión cada 30 segundos
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectionAndSync();
    });
    
    // Verificación inicial
    checkConnectionAndSync();
  }

  Future<void> checkConnectionAndSync() async {
    final wasOnline = _isOnline;
    _isOnline = await _apiService.verificarConexion();
    
    if (_isOnline && !wasOnline) {
      // Acabamos de recuperar la conexión, sincronizar
      await syncPendingOperations();
    }
    
    notifyListeners();
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing || !_isOnline) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // Obtener operaciones pendientes de la cola (solo si no es Web)
      if (kIsWeb) return;
      final queue = await _dbService.getSyncQueue();
      
      for (var item in queue) {
        try {
          await _processSyncItem(item);
          await _dbService.removeSyncQueueItem(item['id'] as int);
        } catch (e) {
          if (kDebugMode) {
            print('Error sincronizando item ${item['id']}: $e');
          }
          // Continuar con el siguiente item aunque falle uno
        }
      }

      // Actualizar contador de operaciones pendientes
      if (!kIsWeb) {
        _pendingOperations = await _dbService.getPendingSyncCount();
      } else {
        _pendingOperations = 0;
      }
      _lastSyncTime = DateTime.now();
      
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final operationType = item['operation_type'] as String;
    final tableName = item['table_name'] as String;
    final dataStr = item['data'] as String;
    
    // Parsear los datos (esto es simplificado, en producción usar JSON)
    final data = _parseData(dataStr);

    switch (tableName) {
      case 'mesas':
        await _syncMesa(operationType, data);
        break;
      case 'productos':
        await _syncProducto(operationType, data);
        break;
      case 'categorias':
        await _syncCategoria(operationType, data);
        break;
      case 'pedidos':
        await _syncPedido(operationType, data);
        break;
    }
  }

  Map<String, dynamic> _parseData(String dataStr) {
    try {
      return json.decode(dataStr) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> _syncMesa(String operationType, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        await _apiService.crearMesa(data);
        break;
      case 'UPDATE':
        final id = int.tryParse(data['id']?.toString() ?? '');
        if (id != null) {
          await _apiService.actualizarMesa(id, data);
        }
        break;
      case 'DELETE':
        final id = int.tryParse(data['id']?.toString() ?? '');
        if (id != null) {
          await _apiService.eliminarMesa(id);
        }
        break;
    }
  }

  Future<void> _syncProducto(String operationType, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        await _apiService.crearProducto(data);
        break;
      case 'UPDATE':
        final id = data['id'] as int?;
        if (id != null) {
          await _apiService.actualizarProducto(id, data);
        }
        break;
      case 'DELETE':
        final id = data['id'] as int?;
        if (id != null) {
          await _apiService.eliminarProducto(id);
        }
        break;
    }
  }

  Future<void> _syncCategoria(String operationType, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        await _apiService.crearCategoria(data['nombre'] as String);
        break;
      case 'DELETE':
        final id = data['id'] as int?;
        if (id != null) {
          await _apiService.eliminarCategoria(id);
        }
        break;
    }
  }

  Future<void> _syncPedido(String operationType, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        await _apiService.crearPedido(data);
        break;
    }
  }

  // Método para forzar sincronización manual
  Future<void> forceSyncNow() async {
    await checkConnectionAndSync();
    if (_isOnline) {
      await syncPendingOperations();
    }
  }

  // Método para cargar datos iniciales desde el servidor
  Future<void> loadInitialData() async {
    if (!_isOnline) return;

    try {
      // Cargar mesas
      final mesas = await _apiService.obtenerMesas();
      if (!kIsWeb) {
        for (var mesaJson in mesas) {
          final mesa = Mesa.fromJson(mesaJson as Map<String, dynamic>);
          await _dbService.insertMesa(mesa);
        }
      }

      // Cargar zonas
      final zonas = await _apiService.obtenerZonas();
      if (!kIsWeb) {
        for (var zonaJson in zonas) {
          final zona = Zona.fromJson(zonaJson as Map<String, dynamic>);
          await _dbService.insertZona(zona);
        }
      }

      // Cargar productos
      final productos = await _apiService.obtenerProductos();
      if (!kIsWeb) {
        for (var productoJson in productos) {
          final producto = Plato.fromMap(productoJson as Map<String, dynamic>);
          await _dbService.insertProducto(producto);
        }
      }

      // Cargar categorías
      final categorias = await _apiService.obtenerCategorias();
      if (!kIsWeb) {
        for (var categoriaJson in categorias) {
          final categoria = Categoria.fromJson(categoriaJson as Map<String, dynamic>);
          await _dbService.insertCategoria(categoria);
        }
      }

      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error cargando datos iniciales: $e');
      }
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
