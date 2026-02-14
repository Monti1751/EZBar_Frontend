class Pedido {
  int? id;
  int mesaId;
  String estado; // 'activo', 'pagado', 'cancelado'
  DateTime fecha;
  List<DetallePedido> detalles;
  String syncStatus; // 'pendiente' o 'sincronizado'

  Pedido({
    this.id,
    required this.mesaId,
    required this.estado,
    required this.fecha,
    List<DetallePedido>? detalles,
    this.syncStatus = 'sincronizado',
  }) : detalles = detalles ?? [];

  // Convertir desde JSON del backend
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int?,
      mesaId: json['mesa_id'] as int? ?? json['mesaId'] as int? ?? 0,
      estado: json['estado'] as String? ?? 'activo',
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
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
      'mesa_id': mesaId,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
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
      'sync_status': syncStatus,
    };
  }

  // Crear desde Map de SQLite
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] as int?,
      mesaId: map['mesa_id'] as int? ?? 0,
      estado: map['estado'] as String? ?? 'activo',
      fecha: DateTime.parse(map['fecha'] as String),
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
  String syncStatus;

  DetallePedido({
    this.id,
    this.pedidoId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.syncStatus = 'sincronizado',
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['id'] as int?,
      pedidoId: json['pedido_id'] as int?,
      productoId: json['producto_id'] as int? ?? 0,
      nombreProducto: json['nombre_producto'] as String? ?? '',
      cantidad: json['cantidad'] as int? ?? 1,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0.0,
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
      'sync_status': syncStatus,
    };
  }

  factory DetallePedido.fromMap(Map<String, dynamic> map) {
    return DetallePedido(
      id: map['id'] as int?,
      pedidoId: map['pedido_id'] as int?,
      productoId: map['producto_id'] as int? ?? 0,
      nombreProducto: map['nombre_producto'] as String? ?? '',
      cantidad: map['cantidad'] as int? ?? 1,
      precioUnitario: (map['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
    );
  }

  double get subtotal => cantidad * precioUnitario;
}
