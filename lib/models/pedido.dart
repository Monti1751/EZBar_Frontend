class Pedido {
  int? id;
  int mesaId;
  String estado; // 'activo', 'pagado', 'cancelado'
  DateTime fecha;
  double totalPedido;
  List<DetallePedido> detalles;
  String syncStatus; // 'pendiente' o 'sincronizado'

  Pedido({
    this.id,
    required this.mesaId,
    required this.estado,
    required this.fecha,
    this.totalPedido = 0.0,
    List<DetallePedido>? detalles,
    this.syncStatus = 'sincronizado',
  }) : detalles = detalles ?? [];

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      if (val.isEmpty) return null;
      // Handle cases like "4.00" which int.tryParse fails on
      return int.tryParse(val) ?? double.tryParse(val)?.toInt();
    }
    return null;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  // Convertir desde JSON del backend
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: _parseInt(json['id']) ?? _parseInt(json['pedido_id']),
      mesaId: _parseInt(json['mesa_id']) ?? _parseInt(json['mesaId']) ?? 0,
      estado: json['estado'] as String? ?? 'activo',
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      totalPedido: _parseDouble(json['total_pedido']),
      detalles: (json['detalles'] as List<dynamic>?)
          ?.map((d) => DetallePedido.fromJson(d as Map<String, dynamic>))
          .toList(),
      syncStatus: 'sincronizado',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pedido_id': id,
      'mesa_id': mesaId,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'total_pedido': totalPedido,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mesa_id': mesaId,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'total_pedido': totalPedido,
      'sync_status': syncStatus,
    };
  }

  // Crear desde Map de SQLite
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: _parseInt(map['id']),
      mesaId: _parseInt(map['mesa_id']) ?? 0,
      estado: map['estado'] as String? ?? 'activo',
      fecha: DateTime.parse(map['fecha'] as String),
      totalPedido: _parseDouble(map['total_pedido']),
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
    );
  }
}

class DetallePedido {
  int? id;
  int? pedidoId;
  int productoId;
  String nombreProducto;
  int cantidad;
  double precioUnitario;
  double? totalLinea;
  String syncStatus;

  DetallePedido({
    this.id,
    this.pedidoId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.totalLinea,
    this.syncStatus = 'sincronizado',
  });

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      if (val.isEmpty) return null;
      // Handle cases like "4.00" which int.tryParse fails on
      return int.tryParse(val) ?? double.tryParse(val)?.toInt();
    }
    return null;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    // Manejar el objeto anidado 'producto' si existe
    final productoJson = json['producto'] as Map<String, dynamic>?;
    
    return DetallePedido(
      id: _parseInt(json['id']) ?? _parseInt(json['detalle_id']),
      pedidoId: _parseInt(json['pedido_id']),
      productoId: _parseInt(json['producto_id']) ?? 
                  _parseInt(productoJson?['producto_id']) ?? 0,
      nombreProducto: json['nombre_producto'] as String? ?? 
                      productoJson?['nombre'] as String? ?? '',
      cantidad: _parseInt(json['cantidad']) ?? 1,
      precioUnitario: _parseDouble(json['precio_unitario']) == 0 ? _parseDouble(productoJson?['precio']) : _parseDouble(json['precio_unitario']),
      totalLinea: json['total_linea'] != null ? _parseDouble(json['total_linea']) : null,
      syncStatus: 'sincronizado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (pedidoId != null) 'pedido_id': pedidoId,
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'total_linea': totalLinea ?? subtotal,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (pedidoId != null) 'pedido_id': pedidoId,
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'total_linea': totalLinea ?? subtotal,
      'sync_status': syncStatus,
    };
  }

  factory DetallePedido.fromMap(Map<String, dynamic> map) {
    return DetallePedido(
      id: _parseInt(map['id']),
      pedidoId: _parseInt(map['pedido_id']),
      productoId: _parseInt(map['producto_id']) ?? 0,
      nombreProducto: map['nombre_producto'] as String? ?? '',
      cantidad: _parseInt(map['cantidad']) ?? 1,
      precioUnitario: _parseDouble(map['precio_unitario']),
      totalLinea: map['total_linea'] != null ? _parseDouble(map['total_linea']) : null,
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
    );
  }

  double get subtotal => cantidad * precioUnitario;
}
