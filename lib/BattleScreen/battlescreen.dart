import 'dart:convert';

import 'package:eturn/BattleScreen/battlegame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

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

    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080'),
    );

    channel.stream.listen((data) {
      final msg = jsonDecode(data);
      game.applySnapshot(msg['snapshot']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          channel.sink.add(jsonEncode({
            'cmd': 'attack',
            'shipId': 1,
            'targetId': 2,
          }));
        },
        child: const Icon(Icons.flash_on),
      ),
    );
  }
}
