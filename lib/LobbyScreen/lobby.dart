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
                TextField(
                  controller: textEditingController,
                  onChanged: (value) {
                    playerId = value;
                  },

                ),
                ElevatedButton(
                  onPressed: () async {
                    if (playerId == null) return;

                    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'),);

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
                  child: Text('connect'))
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
          

          break;
        default:
      }
    } catch (e) {
      print(e);
    }
  }
}