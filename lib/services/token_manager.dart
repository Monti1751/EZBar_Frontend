import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  String? _token;

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  // Guardar token en memoria y SharedPreferences
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('✅ Token guardado: $token');
  }

  // Obtener token desde memoria primero, luego SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) {
      print('✅ Token desde memoria: $_token');
      return _token;
    }

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print('✅ Token desde SharedPreferences: $_token');
    return _token;
  }

  // Obtener token sincronamente (si ya está cargado en memoria)
  String? getTokenSync() => _token;

  // Limpiar token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('✅ Token eliminado');
  }

  // Cargar token al iniciar (para recuperarlo de SharedPreferences)
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print('✅ Token cargado al iniciar: $_token');
  }
}
