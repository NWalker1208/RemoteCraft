import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:remote_craft/services/server_io.dart';

enum _PacketType {
  login, command, response
}

int _typeToInt(_PacketType type) {
  if (type == _PacketType.login)
    return 3;
  else if (type == _PacketType.command)
    return 2;
  else if (type == _PacketType.response)
    return 0;
  else
    return -1;
}

_PacketType _intToType(int type) {
  if (type == 3)
    return _PacketType.login;
  else if (type == 2)
    return _PacketType.command;
  else if (type == 0)
    return _PacketType.response;
  else
    return null;
}

// https://wiki.vg/RCON
class _Packet {
  int id;
  _PacketType type;
  String payload;

  _Packet({this.id, this.type, this.payload = ''});

  _Packet.fromBytes(Uint8List data) {
    // Read integers from packet
    ByteData _length = ByteData(4);
    ByteData _id = ByteData(4);
    ByteData _type = ByteData(4);

    for (int b = 0; b < 4; b++) {
      _length.setUint8(b, data[b]);
      _id.setUint8(b, data[b + 4]);
      _type.setUint8(b, data[b + 8]);
    }

    // Convert bytes of ints
    int payloadLength = _length.getUint32(0, Endian.little) - 10; // Account for preceding ints and double null byte pad
    id = _id.getUint32(0, Endian.little);
    type = _intToType(_type.getUint32(0, Endian.little));

    // Read payload
    List<int> charCodes = List<int>(payloadLength);
    for (int c = 0; c < payloadLength; c++)
      charCodes[c] = data[c + 12];
    payload = String.fromCharCodes(charCodes).trimRight();
  }

  Uint8List toBytes() {
    // Convert properties to byte data
    ByteData length = ByteData(4)..setUint32(0, 10 + payload.length, Endian.little);
    ByteData _id = ByteData(4)..setUint32(0, id, Endian.little);
    ByteData _type = ByteData(4)..setUint32(0, _typeToInt(type), Endian.little);

    // Form list of bytes
    return Uint8List.fromList([
      length.getUint8(0),length.getUint8(1),length.getUint8(2),length.getUint8(3),
      _id.getUint8(0),_id.getUint8(1),_id.getUint8(2),_id.getUint8(3),
      _type.getUint8(0),_type.getUint8(1),_type.getUint8(2),_type.getUint8(3),

      for (int c = 0; c < payload.length; c++)
        payload.codeUnitAt(c),

      0, 0
    ]);
  }

  @override
  String toString() {
    return 'RCON Packet #$id ($type): "$payload"';
  }
}

class RCONConnection {
  Socket _socket;
  bool _authenticated = false;

  bool get connected => _socket != null;
  bool get authenticated => _authenticated;

  FutureOr<void> Function(bool) onAuthenticate;
  FutureOr<void> Function(String) onCommandResponse;

  RCONConnection({String address = 'localhost', int port = 25575,
                  FutureOr<void> Function() onConnect,
                  this.onAuthenticate, this.onCommandResponse}) {
    openSocket(
      address: address,
      port: port,
      listener: _socketListener,
    ).then((socket) {
      _socket = socket;
      onConnect?.call();
    });
  }

  void close() {
    if (connected) {
      _socket.destroy();
      _socket = null;
    }
  }

  void authenticate(String password) {
    if (connected) {
      print('Authenticating on server ${_socket.address.address}...');
      _socket.add(_Packet(id: 1, type: _PacketType.login, payload: password).toBytes());
    }
  }

  int _nextId = 2;
  void sendCommand(String command) {
    if (authenticated) {
      print('Sending command "$command" to server ${_socket.address.address}...');
      _socket.add(_Packet(id: _nextId++, type: _PacketType.command, payload: command).toBytes());
    }
  }

  void _socketListener(Uint8List data) {
    _Packet responsePacket = _Packet.fromBytes(data);

    print('Received response: $responsePacket');

    if (responsePacket.type == _PacketType.command) {
      if (responsePacket.id == 1) {
        _authenticated = true;
        print('RCON session successfully authenticated!');
        onAuthenticate?.call(true);
      } else {
        _authenticated = false;
        print('Authentication failed.');
        onAuthenticate?.call(false);
      }
    } else if (responsePacket.type == _PacketType.response)
      onCommandResponse?.call(responsePacket.payload);
  }
}