class Categoria {
  int? id;
  String nombre;
  String syncStatus; // 'pendiente' o 'sincronizado'

  Categoria({
    this.id,
    required this.nombre,
    this.syncStatus = 'sincronizado',
  });

  // Convertir desde JSON del backend
  factory Categoria.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    return Categoria(
      id: parseId(json['id']) ?? parseId(json['categoria_id']),
      nombre: json['nombre'] as String? ?? '',
      syncStatus: 'sincronizado',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (id != null) 'categoria_id': id,
      'nombre': nombre,
    };
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'sync_status': syncStatus,
    };
  }

  // Crear desde Map de SQLite
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] as int?,
      nombre: map['nombre'] as String? ?? '',
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
    );
  }
}
