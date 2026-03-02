Future<String?> findServerIp() async {
  // En Web asumimos localhost porque no hay UDP discovery
  // O podriamos devolver la IP relativa del navegador si fuera necesario (window.location.hostname)
  // pero localhost:3000 suele ser lo correcto si corren el server local.
  return 'localhost';
}
