class Zona {
  final String nombre;
  final int totalMesas;
  final int mesasLibres;
  final int mesasOcupadas;
  final String syncStatus; // "pendiente" o "sincronizado"

  Zona({
    required this.nombre,
    required this.totalMesas,
    required this.mesasLibres,
    required this.mesasOcupadas,
    this.syncStatus = 'sincronizado',
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      nombre: json['nombre'] as String? ?? '',
      totalMesas: json['total_mesas'] as int? ?? 0,
      mesasLibres: json['mesas_libres'] as int? ?? 0,
      mesasOcupadas: json['mesas_ocupadas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'total_mesas': totalMesas,
      'mesas_libres': mesasLibres,
      'mesas_ocupadas': mesasOcupadas,
    };
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'total_mesas': totalMesas,
      'mesas_libres': mesasLibres,
      'mesas_ocupadas': mesasOcupadas,
      'sync_status': syncStatus,
    };
  }

  // Crear desde Map de SQLite
  factory Zona.fromMap(Map<String, dynamic> map) {
    return Zona(
      nombre: map['nombre'] as String? ?? '',
      totalMesas: map['total_mesas'] as int? ?? 0,
      mesasLibres: map['mesas_libres'] as int? ?? 0,
      mesasOcupadas: map['mesas_ocupadas'] as int? ?? 0,
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
    );
  }

  double get porcentajeOcupacion {
    if (totalMesas == 0) return 0.0;
    return (mesasOcupadas / totalMesas) * 100;
  }
}