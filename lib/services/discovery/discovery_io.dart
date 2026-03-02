import 'dart:convert';
import 'dart:io';

Future<String?> findServerIp() async {
  // print('🔍 Iniciando descubrimiento de servidor (UDP IO)...');
  try {
    RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    socket.broadcastEnabled = true;

    // Enviar solicitud varias veces para asegurar entrega (UDP es no confiable)
    List<int> data = utf8.encode('EZBAR_DISCOVER');
    for (int i = 0; i < 3; i++) {
      socket.send(data, InternetAddress('255.255.255.255'), 3001);
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Esperar respuesta (max 5 segundos)
    String? foundIp;

    await for (RawSocketEvent event in socket.timeout(Duration(seconds: 5))) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();
        if (dg != null) {
          String response = utf8.decode(dg.data);
          // print('📩 Respuesta recibida: $response');
          try {
            Map<String, dynamic> json = jsonDecode(response);
            if (json['service'] == 'EZBar_API') {
              foundIp = json['ip'];
              // int port = json['port'];
              socket.close();
              return foundIp;
            }
          } catch (e) {
            // print('Error parseando respuesta: $e');
          }
        }
      }
    }
    socket.close();
    return null;
  } catch (e) {
    // print('❌ Error en descubrimiento UDP: $e');
    return null;
  }
}
