import 'dart:async';

import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/socket.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BattleScreen2 extends StatefulWidget {
  const BattleScreen2({super.key});
  //final Map<String, dynamic> initData;

  @override
  State<BattleScreen2> createState() => _BattleScreen2State();
}

class _BattleScreen2State extends State<BattleScreen2> {

  late StreamSubscription sub;
  final Map<int, Map<String, dynamic>> ships = {};
  Vector2 world00 = Vector2(0, 0), world11 = Vector2(200000, 200000);
  late Vector2 screen00 = Vector2.zero(), screen11;


  @override
  void initState() {
    super.initState();
    //handleData(widget.initData);
    sub = SocketService().stream.listen(handleData);
  }

  @override
  Widget build(BuildContext context) {
    screen11 = Vector2(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    printD(screen11.toString());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              ...ships.entries.map((s) {
                printD(s.toString());
                printD((s.value['ship']['pos']['x'] * screen11.x / world11.x).toString());
                //if (s.key == me?.id) return Positioned(child: child)
                return Positioned(
                  left: s.value['ship']['pos']['x'] * screen11.x / world11.x + screen11.x / 2,
                  top: s.value['ship']['pos']['y'] * screen11.y / world11.y + screen11.y / 2,
                  child: drawShip(s)
                );}
              )
            ],
          ),
        )
      ),
    );
  }

  void handleData(Map<String, dynamic> data) {
    printD('handleData:');
    for (final player in data['data']) {
      final id = player['ship']['id'];
      printD('shipComponentID: $id');
      printD('ship=\n$player');
      setState(() {
        player['ship_DB']['team'] = player['ship']['team'];
        //player['ship_DB']['pos'] = player['ship']['pos'];
        //player['ship_DB']['ship_class'] = player['ship_class'];
        ships[id] = player;
      });
    }
  }
  
  Widget drawShip(MapEntry<int, Map<String, dynamic>> s) {
    final id = s.key;
    final ship = s.value;
    return Container(
      width: ship['ship_DB']['radius'] * screen11.x / world11.x >= 30 ? ship['ship_DB']['radius'] * screen11.x / world11.x : 30,
      height: ship['ship_DB']['radius'] * screen11.y / world11.y >= 30 ? ship['ship_DB']['radius'] * screen11.y / world11.y : 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black
        //ship['radius'] * screen11.x / world11.x,
        //color: ship['team'] < 0 ? Colors.blue : Colors.red
      ),
    );
  }
}