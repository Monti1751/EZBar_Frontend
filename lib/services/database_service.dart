import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mesa.dart';
import '../models/zona.dart';
import '../models/plato.dart';
import '../models/categoria.dart';
import '../models/pedido.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'ezbar_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de mesas
    await db.execute('''
      CREATE TABLE mesas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        numero_mesa INTEGER NOT NULL,
        capacidad INTEGER NOT NULL,
        estado TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        local_id TEXT
      )
    ''');

    // Tabla de zonas
    await db.execute('''
      CREATE TABLE zonas (
        nombre TEXT PRIMARY KEY,
        total_mesas INTEGER NOT NULL,
        mesas_libres INTEGER NOT NULL,
        mesas_ocupadas INTEGER NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');

    // Tabla de productos/platos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        imagen_blob TEXT,
        imagen_url TEXT,
        ingredientes TEXT,
        extras TEXT,
        alergenos TEXT,
        sync_status TEXT NOT NULL,
        local_id TEXT
      )
    ''');

    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');

    // Tabla de pedidos
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY,
        mesa_id INTEGER NOT NULL,
        estado TEXT NOT NULL,
        fecha TEXT NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');

    // Tabla de detalles de pedidos
    await db.execute('''
      CREATE TABLE detalles_pedido (
        id INTEGER PRIMARY KEY,
        pedido_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        nombre_producto TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de cola de sincronización
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // ==================== MÉTODOS CRUD PARA MESAS ====================

  Future<int> insertMesa(Mesa mesa) async {
    final db = await database;
    await db.insert('mesas', mesa.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return 1;
  }

  Future<List<Mesa>> getMesas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mesas');
    return List.generate(maps.length, (i) => Mesa.fromMap(maps[i]));
  }

  Future<List<Mesa>> getMesasPorZona(String ubicacion) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mesas',
      where: 'ubicacion = ?',
      whereArgs: [ubicacion],
    );
    return List.generate(maps.length, (i) => Mesa.fromMap(maps[i]));
  }

  Future<int> updateMesa(Mesa mesa) async {
    final db = await database;
    return await db.update(
      'mesas',
      mesa.toMap(),
      where: 'id = ?',
      whereArgs: [mesa.id],
    );
  }

  Future<int> deleteMesa(String id) async {
    final db = await database;
    return await db.delete(
      'mesas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MÉTODOS CRUD PARA ZONAS ====================

  Future<int> insertZona(Zona zona) async {
    final db = await database;
    await db.insert('zonas', zona.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return 1;
  }

  Future<List<Zona>> getZonas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('zonas');
    return List.generate(maps.length, (i) => Zona.fromMap(maps[i]));
  }

  Future<int> updateZona(Zona zona) async {
    final db = await database;
    return await db.update(
      'zonas',
      zona.toMap(),
      where: 'nombre = ?',
      whereArgs: [zona.nombre],
    );
  }

  Future<int> deleteZona(String nombre) async {
    final db = await database;
    return await db.delete(
      'zonas',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
  }

  // ==================== MÉTODOS CRUD PARA PRODUCTOS ====================

  Future<int> insertProducto(Plato producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Plato>> getProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) => Plato.fromMap(maps[i]));
  }

  Future<int> updateProducto(Plato producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MÉTODOS CRUD PARA CATEGORÍAS ====================

  Future<int> insertCategoria(Categoria categoria) async {
    final db = await database;
    return await db.insert('categorias', categoria.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Categoria>> getCategorias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categorias');
    return List.generate(maps.length, (i) => Categoria.fromMap(maps[i]));
  }

  Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MÉTODOS CRUD PARA PEDIDOS ====================

  Future<int> insertPedido(Pedido pedido) async {
    final db = await database;
    return await db.insert('pedidos', pedido.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Pedido>> getPedidos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pedidos');
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<int> insertDetallePedido(DetallePedido detalle) async {
    final db = await database;
    return await db.insert('detalles_pedido', detalle.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DetallePedido>> getDetallesPedido(int pedidoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'detalles_pedido',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );
    return List.generate(maps.length, (i) => DetallePedido.fromMap(maps[i]));
  }

  // ==================== MÉTODOS PARA COLA DE SINCRONIZACIÓN ====================

  Future<int> addToSyncQueue(String operationType, String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'operation_type': operationType,
      'table_name': tableName,
      'data': data.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  Future<int> removeSyncQueueItem(int id) async {
    final db = await database;
    return await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  // ==================== MÉTODOS DE UTILIDAD ====================

  Future<int> getPendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('mesas');
    await db.delete('zonas');
    await db.delete('productos');
    await db.delete('categorias');
    await db.delete('pedidos');
    await db.delete('detalles_pedido');
    await db.delete('sync_queue');
  }
}
