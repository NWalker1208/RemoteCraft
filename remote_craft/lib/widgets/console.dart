import 'package:flutter/material.dart';
import 'package:remote_craft/services/rcon.dart';
import 'dart:io';
import 'package:remote_craft/services/server_io.dart';

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

  String password;
  List<String> responses;

  @override
  void initState() {
    password = '';
    responses = List<String>();
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
            itemBuilder: (context, i) => Text(responses[i])
          )
        ),

        TextField(
          onSubmitted: (pw) => setState(() {
            password = pw;
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Start Server'),
              onPressed: () async {
                ServerSocket temp = await startServer(port: 25575);
                setState(() => server = temp);
              },
            ),
            RaisedButton(
              child: Text('Open Socket'),
              onPressed: server == null ? null : () {
                setState(() => rconConnection = RCONConnection(widget.serverAddress, port: widget.port));
              },
            ),
            RaisedButton(
              child: Text('Authenticate'),
              onPressed: rconConnection == null ? null : () => rconConnection.authenticate(password),
            )
          ],
        ),
      ],
    );
  }
}

