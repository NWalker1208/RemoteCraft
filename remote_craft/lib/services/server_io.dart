import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:socket_io/socket_io.dart' as SIO;

SIO.Server startServer({int port}) {
  var server = new SIO.Server();
  server.on('connection', (client) {
    print('connection default namespace');
    client.on('msg', (data) {
      print('data from default => $data');
      client.emit('fromServer', "ok");
    });
  });
  server.listen(port);

  return server;
}

Future<Socket> openSocket({String address, int port}) async {
  // Dart client
  print('Opening socket to $address:$port');
  Socket socket = await Socket.connect(address, port);
  print('Connected to $address:$port');

  // listen to the received data event stream
  socket.listen((List<int> event) {
    print(utf8.decode(event));
  });

  // send hello
  print('Sending \'hello\'');
  socket.add(utf8.encode('hello'));

  return socket;
}