class ApiConfig {
  // URL base de la API Node.js
  static const String baseUrl = 'https://euphoniously-subpatellar-chandra.ngrok-free.dev';  

  // Para dispositivos Android (emulador)
  // static const String baseUrl = 'http://10.0.2.2:3000';

  // Para dispositivos iOS (simulador)
  // static const String baseUrl = 'http://localhost:8080/api';

  // Para dispositivos físicos (Tu IP local detectada)
  //static const String baseUrl = 'http://172.20.10.5:3000';

  // Endpoints
  static const String mesas = '$baseUrl/api/mesas';
  static const String pedidos = '$baseUrl/api/pedidos';
  static const String productos = '$baseUrl/api/productos';
  static const String zonas = '$baseUrl/api/zonas';
  static const String categorias = '$baseUrl/api/categorias';
}
