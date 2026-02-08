import 'dart:async';
import 'dart:convert';

import 'package:eturn/Screens/station.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/player.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late StreamSubscription sub;
  String? email, password;
  Map<String, String> logins = {};

  @override
  void initState() {
    super.initState();

    loadSavedLogins();

    sub = SocketService().stream.listen((event) {
      if (event['category'] == 'connection' && event['type'] == 'login' && !event['result']) {
        // auth failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sorry! Authentication is failed!')));
      }

      if (event['category'] == 'connection' && event['type'] == 'login' && event['result']) {
        me['id'] = event['player']['id']; //;
        saveLogin(); 
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
                    printD('sending:\n$data');
                    SocketService().send(data);
                  },
                  child: Text('connect')
                ),
                Row(
                  children: [
                    ...logins.entries.map((l) => ElevatedButton(
                      child: Text(l.key),
                      onPressed: () {
                        final data = {'category': 'connection', 'type': 'login', 'email': l.key, 'password': l.value};
                        printD('sending:\n$data');
                        SocketService().send(data);
                      },
                    ))
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }
  
  void loadSavedLogins() async {
    var shared = await SharedPreferences.getInstance();
    var strings = shared.getString('logins');
    if (strings != null && strings.isNotEmpty) {
      setState(() {
        Map<String, dynamic> decoded = jsonDecode(strings);
        printD(decoded.toString());
        decoded.forEach((s, d) {
          logins[s] = d.toString();
        });
      });
    }
  }
  
  void saveLogin() async {
    var shared = await SharedPreferences.getInstance();
    if (email != null && password != null) logins[email!] = password!;
    shared.setString('logins', jsonEncode(logins));
  }
}