import 'package:flutter/material.dart';
import 'dart:io';
import 'package:remote_craft/services/server_io.dart';
import 'package:socket_io/socket_io.dart' as SIO;

class Console extends StatefulWidget {
  @override
  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  SIO.Server server;
  Socket socket;

  List<String> responses;

  @override
  void initState() {
    responses = List<String>();
    super.initState();
  }

  @override
  void dispose() {
    if (socket != null)
      socket.close();
    if (server != null)
      server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, i) => Text(responses[i])
          )
        ),

        TextField(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Start Server'),
              onPressed: () {
                setState(() {
                  server = startServer(port: 25575);
                });
              },
            ),
            RaisedButton(
              child: Text('Open Socket'), 
              onPressed: server == null ? null : () async {
                Socket s = await openSocket(address: '0.0.0.0', port: 25575);
                setState(() {
                  socket = s;
                });
              },
            )
          ],
        ),
      ],
    );
  }
}

