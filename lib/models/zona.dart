class Zona {
  final String nombre;
  final int totalMesas;
  final int mesasLibres;
  final int mesasOcupadas;

  Zona({
    required this.nombre,
    required this.totalMesas,
    required this.mesasLibres,
    required this.mesasOcupadas,
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

  double get porcentajeOcupacion {
    if (totalMesas == 0) return 0.0;
    return (mesasOcupadas / totalMesas) * 100;
  }
}