import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../visual_settings_provider.dart';

/// === MODELO DE MESA ===
class Mesa {
  String id;
  String name;
  String estado; // "libre", "reservado", "ocupado"
  String ubicacion;
  int numeroMesa;
  int capacidad;

  Mesa({
    required this.id,
    required this.name,
    required this.ubicacion,
    required this.numeroMesa,
    required this.capacidad,
    this.estado = "libre",
  });

  // Convertir desde JSON del backend
  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['mesa_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['nombre'] ?? json['name'] ?? 'Mesa ${json['numero_mesa'] ?? ''}',
      ubicacion: json['ubicacion'] ?? '',
      numeroMesa: json['numero_mesa'] ?? json['numeroMesa'] ?? json['numero'] ?? 0,
      capacidad: json['capacidad'] ?? 4,
      estado: json['estado'] ?? 'libre',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (int.tryParse(id) != null) 'id': int.parse(id),
      'nombre': name,
      'ubicacion': ubicacion,
      'numero_mesa': numeroMesa,
      'capacidad': capacidad,
      'estado': estado,
    };
  }

  void setEstado(int disposicion) {
    switch (disposicion) {
      case 1:
        estado = "libre";
        break;
      case 2:
        estado = "reservado";
        break;
      case 3:
        estado = "ocupado";
        break;
      default:
        estado = "libre";
    }
  }

  Color getColorByEstado(BuildContext context) {
    final settings = Provider.of<VisualSettingsProvider>(context, listen: false);
    if (settings.colorBlindMode) {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.blue;
        case 'reservado':
          return Colors.orange;
        case 'ocupado':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    } else {
      switch (estado.toLowerCase()) {
        case 'libre':
          return Colors.green;
        case 'reservado':
          return Colors.orange;
        case 'ocupado':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }

  /// Badge discreto: solo borde y texto con el color del estado
  Widget getEstadoBadge(BuildContext context) {
    final Color color = getColorByEstado(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ).copyWith(color: color),
      ),
    );
  }
}
