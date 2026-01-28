import 'package:eturn/Screens/login.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';

void main() {
  final socket = SocketService();
  socket.connect('ws://192.168.10.75:8080');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}
