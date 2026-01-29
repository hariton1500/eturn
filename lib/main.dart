import 'package:eturn/Screens/login.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  Supabase.initialize(url: dotenv.get('url', fallback: ''), anonKey: dotenv.get('key', fallback: ''));
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
