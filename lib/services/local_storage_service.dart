import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zona.dart';
import '../models/mesa.dart';

class LocalStorageService {
  static const String _zonesKey = 'local_zones';
  static const String _tablesKeyPrefix = 'local_tables_';

  // --- ZONES ---

  Future<void> saveZones(List<Zone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(zones.map((z) => z.toJson()).toList());
    await prefs.setString(_zonesKey, encodedData);
  }

  Future<List<Zone>> getZones() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_zonesKey)) return [];

    final String? encodedData = prefs.getString(_zonesKey);
    if (encodedData == null) return [];

    try {
      final List<dynamic> decodedData = json.decode(encodedData);
      return decodedData.map((item) => Zone.fromJson(item)).toList();
    } catch (e) {
      print("Error decoding local zones: $e");
      return [];
    }
  }

  // --- TABLES ---

  // Guarda las mesas de una zona específica
  Future<void> saveTables(String zoneName, List<Mesa> tables) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getImageKey(zoneName);
    final String encodedData = json.encode(tables.map((t) => t.toJson()).toList());
    await prefs.setString(key, encodedData);
  }

  // Recupera las mesas de una zona específica
  Future<List<Mesa>> getTables(String zoneName) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getImageKey(zoneName);
    
    if (!prefs.containsKey(key)) return [];
    
    final String? encodedData = prefs.getString(key);
    if (encodedData == null) return [];

    try {
      final List<dynamic> decodedData = json.decode(encodedData);
      return decodedData.map((item) => Mesa.fromJson(item)).toList();
    } catch (e) {
      print("Error decoding local tables for $zoneName: $e");
      return [];
    }
  }

  // Elimina las mesas guardadas de una zona (usado cuando se elimina la zona)
  Future<void> removeTables(String zoneName) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getImageKey(zoneName);
    await prefs.remove(key);
  }

  String _getImageKey(String zoneName) {
    // Usamos el nombre de la zona como identificador, asegurándonos que sea seguro
    return '$_tablesKeyPrefix${zoneName.replaceAll(RegExp(r'\s+'), '_')}';
  }
}
