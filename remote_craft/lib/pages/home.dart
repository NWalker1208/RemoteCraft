import 'package:flutter/material.dart';
import 'package:remote_craft/widgets/console.dart';

class HomePage extends StatelessWidget {
  final String serverAddress;
  final int port;

  HomePage({this.serverAddress, this.port});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RemoteCraft'),
      ),

      body: Console(serverAddress: serverAddress, port: port),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.laptop_windows),
            title: Text('Console'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            title: Text('World'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Users'),
          ),
        ],
      ),
    );
  }
}
