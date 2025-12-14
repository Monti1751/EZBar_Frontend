import 'mesa.dart';

/// === MODELO DE ZONA ===
class Zone {
  String? id;
  String name;
  bool isOpen = false;
  List<Mesa> tables = [];

  Zone({this.id, required this.name});

  // ✅ Convertir desde JSON del backend (adaptado para el nuevo formato)
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['nombre']?.toString(), // Usa 'nombre' como ID
      name: json['nombre'] ?? json['name'] ?? '',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
    };
  }
}