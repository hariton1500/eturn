import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {

  TextEditingController? textEditingController;
  late WebSocketChannel channel;
  String? playerId;
  bool isConnectedToLobby = false;
  List<Map<String, dynamic>> players = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                if (!isConnectedToLobby) TextField(
                  controller: textEditingController,
                  onChanged: (value) {
                    playerId = value;
                  },

                ),
                if (!isConnectedToLobby) ElevatedButton(
                  onPressed: () async {
                    if (playerId == null) return;

                    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.10.75:8080'),);

                    try {
                      await channel.ready;
                    } on SocketException catch (e) {
                      // Handle the exception.
                    } on WebSocketChannelException catch (e) {
                      // Handle the exception.
                    }

                    // If `ready` completes without an error then the channel is ready to
                    // send data.
                    channel.sink.add(jsonEncode({'type': 'join_lobby', 'playerId': playerId}));
                    channel.stream.listen((data) {
                      final msg = jsonDecode(data);
                      print('[${DateTime.now()}] $msg');
                      handleLobbyIncomeMessages(msg, channel);
                      //game.applySnapshot(msg['snapshot']);
                    });
                  },
                  child: Text('connect')
                ),
                if (isConnectedToLobby) ... players.map((e) => Text(e.toString()))
              ],
            ),
          ),
        )
      ),
    );
  }
  
  void handleLobbyIncomeMessages(Map<String, dynamic> msg, WebSocketChannel channel) {
    try {
      switch (msg['type']) {
        case 'lobby_state':
          final locked = msg['locked'];
          players.clear();
          players.addAll((msg['players'] as List).map((e) => {'id': e['id'], 'ready': e['ready']}));// = msg['players'] as Map<String, dynamic>;
          setState(() {
            
          });
          break;
        case 'lobby_connected':
          setState(() {
            isConnectedToLobby = true;
          });
        default:
      }
    } catch (e) {
      print(e);
    }
  }
}