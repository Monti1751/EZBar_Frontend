import 'package:log_in/services/discovery/discovery_service.dart';

class ApiConfig {
  // CONFIGURACIÓN DE MODO:
  // 0 = Web / Localhost
  // 1 = APK / Ngrok Remoto
  // 2 = Mock / Offline (Sin backend)
  static const int mode = 2;

  // Inicialmente vacio o fallback según el modo
  static String baseUrl = mode == 0
      ? 'http://localhost:3000'
      : 'https://pseudospherical-shirlee-lobeliaceous.ngrok-free.dev';
  static bool isConfigured = false;

  // Endpoints dinamicos
  static String get mesas => '$baseUrl/api/mesas';
  static String get pedidos => '$baseUrl/api/pedidos';
  static String get productos => '$baseUrl/api/productos';
  static String get zonas => '$baseUrl/api/zonas';
  static String get categorias => '$baseUrl/api/categorias';

  // Metodo para auto-descubrir servidor via UDP (o Web fallback)
  static Future<bool> findServer() async {
    // Si estamos en modo APK/Ngrok (1) o Web/Local (0) con URL fija, usamos la URL configurada.
    // Solo buscamos si el modo implica BÚSQUEDA (que podria ser un modo 2, por ejemplo)
    // O simplemente asumimos que si hay una URL definida en mode 1, la usamos.
    if (mode == 1 && baseUrl.contains('ngrok')) {
      isConfigured = true;
      print('🚀 Modo Ngrok activo. Usando: $baseUrl');
      return true;
    }

    if (mode == 2) {
      isConfigured = true;
      print('⚡ Modo Mock activo. Sin conexión al backend.');
      return true;
    }

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

  static void setManualIp(String ip) {
    if (ip.isEmpty) return;
    String cleanIp = ip.trim();

    // Si no tiene esquema, agregar http por defecto (salvo que sea ngrok que suele ser https)
    if (!cleanIp.startsWith('http://') && !cleanIp.startsWith('https://')) {
      // Si parece un dominio ngrok, preferir https
      if (cleanIp.contains('ngrok')) {
        cleanIp = 'https://$cleanIp';
      } else {
        cleanIp = 'http://$cleanIp';
      }
    }

    // Validar si tiene puerto.
    // Solo forzamos el puerto 3000 si NO es https y NO es un dominio de ngrok.
    // Los tuneles de ngrok (https) usan el puerto 443 implicito, no se debe agregar :3000 al final.
    final uri = Uri.tryParse(cleanIp);
    if (uri != null) {
      // Si no tiene puerto explicado y no es ngrok/https, asumimos 3000 para desarrollo local
      if (!cleanIp.contains('ngrok') && uri.port == 0) {
        // uri.port es 0 si no se especifica y el esquema no tiene puerto por defecto conocido o es http simple sin puerto
        // Una forma mas robusta de chequear si string termina en :digitos
        if (!RegExp(r':\d+$').hasMatch(cleanIp)) {
          cleanIp = '$cleanIp:3000';
        }
      }
    }

    baseUrl = cleanIp;
    isConfigured = true;
    print('✏️ IP configurada manualmente: $baseUrl');
  }
}
