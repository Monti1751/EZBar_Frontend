import 'dart:convert';
import 'dart:io';

Future<String?> findServerIp() async {
  print('🔍 Iniciando descubrimiento de servidor (UDP IO)...');
  try {
    RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    socket.broadcastEnabled = true;

    // Enviar solicitud
    List<int> data = utf8.encode('EZBAR_DISCOVER');
    socket.send(data, InternetAddress('255.255.255.255'), 3001);

    // Esperar respuesta (max 3 segundos)
    String? foundIp;

    await for (RawSocketEvent event in socket.timeout(Duration(seconds: 3))) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();
        if (dg != null) {
          String response = utf8.decode(dg.data);
          print('📩 Respuesta recibida: $response');
          try {
            Map<String, dynamic> json = jsonDecode(response);
            if (json['service'] == 'EZBar_API') {
              foundIp = json['ip'];
              int port =
                  json['port']; // Podriamos devolver el puerto tambien si cambiase
              // Por ahora solo devolvemos la IP
              socket.close();
              return foundIp;
            }
          } catch (e) {
            print('Error parseando respuesta: $e');
          }
        }
      }
    }
    socket.close();
    return null;
  } catch (e) {
    print('❌ Error en descubrimiento UDP: $e');
    return null;
  }
}
