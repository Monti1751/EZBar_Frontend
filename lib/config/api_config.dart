class ApiConfig {
  // URL base de la API Node.js
  static const String baseUrl = 'http://10.2.1.113:3000/api';
  
  // Para dispositivos Android (emulador)
  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Para dispositivos iOS (simulador)
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // Para dispositivos físicos (usar IP de tu ordenador)
  // static const String baseUrl = 'http://192.168.1.XXX:3000/api';
  
  // Endpoints
  static const String mesas = '$baseUrl/mesas';
  static const String pedidos = '$baseUrl/pedidos';
  static const String productos = '$baseUrl/productos';
  static const String zonas     = '$baseUrl/zonas'; 
}