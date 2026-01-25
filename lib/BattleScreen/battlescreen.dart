import 'dart:async';
import 'dart:convert';

import 'package:eturn/BattleScreen/battlegame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.streamSubscription, required this.channel});
  final StreamSubscription streamSubscription;
  final WebSocketChannel channel;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late WebSocketChannel channel;
  late BattleGame game;

  @override
  void initState() {
    super.initState();
    game = BattleGame();
    widget.streamSubscription.onData((s) => handleData(s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.channel.sink.add(jsonEncode({
            'cmd': 'attack',
            'shipId': 1,
            'targetId': 2,
          }));
        },
        child: const Icon(Icons.flash_on),
      ),
    );
  }

  void handleData(String data) {
      final msg = jsonDecode(data);
      game.applySnapshot(msg['snapshot']);
  }
}
