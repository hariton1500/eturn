import 'dart:async';

import 'package:eturn/funcs.dart';
import 'package:eturn/models/socket.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BattleScreen2 extends StatefulWidget {
  const BattleScreen2({super.key, required this.initData});
  final Map<String, dynamic> initData;

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
    handleData(widget.initData);
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
                printD((s.value['pos']['x'] * screen11.x / world11.x).toString());
                return Positioned(
                  left: s.value['pos']['x'] * screen11.x / world11.x + screen11.x / 2,
                  top: s.value['pos']['y'] * screen11.y / world11.y + screen11.y / 2,
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
    for (final ship in data['ships']) {
      final id = ship['ship']['id'];
      printD('shipComponentID: $id');
      printD('ship=\n$ship');
      setState(() {
        ship['ship_DB']['team'] = ship['ship']['team'];
        ship['ship_DB']['pos'] = ship['ship']['pos'];
        ship['ship_DB']['ship_class'] = ship['ship_class'];
        ships[id] = ship['ship_DB'];
      });
    }
  }
  
  Widget drawShip(MapEntry<int, Map<String, dynamic>> s) {
    final id = s.key;
    final ship = s.value;
    return Container(
      width: ship['radius'] * screen11.x / world11.x >= 30 ? ship['radius'] * screen11.x / world11.x : 30,
      height: ship['radius'] * screen11.y / world11.y >= 30 ? ship['radius'] * screen11.y / world11.y : 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black
        //ship['radius'] * screen11.x / world11.x,
        //color: ship['team'] < 0 ? Colors.blue : Colors.red
      ),
    );
  }
}