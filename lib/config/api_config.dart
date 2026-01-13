import 'package:log_in/services/discovery/discovery_service.dart';

class ApiConfig {
  // Inicialmente vacio o fallback
  static String baseUrl = 'http://10.250.218.56:3000';
  static bool isConfigured = false;

  // Endpoints dinamicos
  static String get mesas => '$baseUrl/api/mesas';
  static String get pedidos => '$baseUrl/api/pedidos';
  static String get productos => '$baseUrl/api/productos';
  static String get zonas => '$baseUrl/api/zonas';
  static String get categorias => '$baseUrl/api/categorias';

  // Metodo para auto-descubrir servidor via UDP (o Web fallback)
  static Future<bool> findServer() async {
    print('🔍 Iniciando descubrimiento de servidor...');

    String? ip = await findServerIp();

    if (ip != null) {
      // En Web puede devolver 'localhost' o una IP real
      if (ip == 'localhost') {
        baseUrl = 'http://localhost:3000';
      } else {
        baseUrl = 'http://$ip:3000';
      }
      isConfigured = true;
      print('✅ Servidor configurado en: $baseUrl');
      return true;
    }

    print('❌ No se encontró servidor (o error en descubrimiento)');
    return false;
  }
}
