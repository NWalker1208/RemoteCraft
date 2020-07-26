import 'package:flutter/material.dart';
import 'dart:io';
import 'package:remote_craft/services/rcon.dart';
import 'package:remote_craft/widgets/server_response.dart';

class Console extends StatefulWidget {
  final String serverAddress;
  final int port;

  Console({this.serverAddress, this.port});

  @override
  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  ServerSocket server;
  RCONConnection rconConnection;

  String textEntry;
  List<String> responses;

  @override
  void initState() {
    textEntry = '';
    responses = List<String>();
    rconConnection = RCONConnection(
      address: widget.serverAddress,
      port: widget.port,
      onConnect: () => setState(() => responses.add('Connected!')),
      onAuthenticate: (success) => setState(() => responses.add(success ? 'Authentication successful' : 'Incorrect password')),
      onCommandResponse: (response) => setState(() => responses.add(response))
    );

    super.initState();
  }

  @override
  void dispose() {
    if (rconConnection != null)
      rconConnection.close();
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
            itemBuilder: (context, i) => ServerResponse(responses[i])
          )
        ),

        TextField(
          onChanged: (text) => setState(() {
            textEntry = text;
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Authenticate'),
              onPressed: rconConnection == null ? null : () => rconConnection.authenticate(textEntry),
            ),
            RaisedButton(
              child: Text('Send Command'),
              onPressed: rconConnection == null ? null : () => rconConnection.sendCommand(textEntry),
            )
          ],
        ),
      ],
    );
  }
}

