class ApiConfig {
  // URL base de la API Node.js
  static const String baseUrl = 'http://localhost:8080';

  // Para dispositivos Android (emulador)
  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Para dispositivos iOS (simulador)
  // static const String baseUrl = 'http://localhost:8080/api';

  // Para dispositivos físicos (usar IP de tu ordenador)
  // static const String baseUrl = 'http://192.168.1.XXX:8080/api';

  // Endpoints
  static const String mesas = '$baseUrl/api/measas';
  static const String pedidos = '$baseUrl/api/pedidos';
  static const String productos = '$baseUrl/api/productos';
  static const String zonas     = '$baseUrl/api/zonas'; 
}
