import 'dart:async';

import 'package:eturn/Screens/station.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late StreamSubscription sub;
  String? email, password;

  @override
  void initState() {
    super.initState();

    sub = SocketService().stream.listen((event) {
      if (event['category'] == 'connection' && event['type'] == 'login' && !event['result']) {
        // auth failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sorry! Authentication is failed!')));
      }

      if (event['category'] == 'connection' && event['type'] == 'login' && event['result']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    sub.cancel(); // 🔥 ОБЯЗАТЕЛЬНО
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication:'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                TextField(
                  //controller: textEditingController,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                TextField(
                  //controller: textEditingController,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (email == null) return;

                    final data = {'category': 'connection', 'type': 'login', 'email': email, 'password': password};
                    print('sending:\n$data');
                    SocketService().send(data);
                  },
                  child: Text('connect')
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}