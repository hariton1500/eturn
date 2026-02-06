import 'dart:async';
import 'package:eturn/BattleScreen/battlegame.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/models/socket.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.initData});
  final Map<String, dynamic> initData;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late StreamSubscription sub;
  late BattleGame game;

  @override
  void initState() {
    super.initState();
    game = BattleGame();
    handleData(widget.initData);
    //sub.onData((s) => handleData(s));
    sub = SocketService().stream.listen(handleData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SocketService().send({
            'cmd': 'attack',
            'shipId': 1,
            'targetId': 2,
          });
        },
        child: const Icon(Icons.flash_on),
      ),
    );
  }

  void handleData(Map<String, dynamic> data) {
      //final msg = jsonDecode(data);
      printD('applySnapshot');
      game.applySnapshot(data);
  }
}
