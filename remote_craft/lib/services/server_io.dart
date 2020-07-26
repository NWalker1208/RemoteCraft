import 'dart:io';
import 'dart:async';

import 'dart:typed_data';

Future<ServerSocket> startServer({int port}) async {
  ServerSocket server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
  server.listen(_handleClient);
  return server;
}

void _handleClient(Socket client){
  print('Connection from: ${client.remoteAddress.address}:${client.remotePort}');
  client.write("Hello from simple server!\n");
  client.close();
}

Future<Socket> openSocket({String address, int port, FutureOr<void> Function(Uint8List) listener}) async {
  Socket socket = await Socket.connect(address, port);
  socket.listen(
    (Uint8List data) {
      print('Client received: ' + data.toList().toString()); // String.fromCharCodes(data).trim());
      listener?.call(data);
    },
    onDone: () {
      print("Connection closed");
      socket.destroy();
    }
  );
  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
  return socket;
}
