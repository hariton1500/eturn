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
  double shiftX = 0, shiftY = 0;
  double rollZoom = 0.9;
  Offset lastTapDown = Offset.zero, zoom = Offset(1, 1);
  double zoomZ = 1 / 200000, camX = 0, camY = 0, screenCX = 0, screenCY = 0;


  @override
  void initState() {
    super.initState();
    //handleData(widget.initData);
    sub = SocketService().stream.listen(handleData);
  }

  @override
  Widget build(BuildContext context) {
    //screen11 = Vector2(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    screenCX = MediaQuery.of(context).size.width / 2;
    screenCY = MediaQuery.of(context).size.height / 2;
    zoomZ = 1 / 400000;
    //zoom = Offset(screen11.x / world11.x, screen11.y / world11.y);
    printD(lastTapDown.toString());
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        toolbarHeight: 100,
        title: Text('$ships/n$me ${camX + (lastTapDown.dx - screenCX) / zoomZ}'),
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onDoubleTap: () {
              printD('on tapdown');
              sendMoveToCommand();
            },
            onTapDown: (details) {
              printD('on tapdown $details');
              lastTapDown = details.globalPosition;
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  ...ships.entries.map((s) {
                    //printD(s.toString());
                    //printD((s.value['ship']['pos']['x'] * screen11.x / world11.x).toString());
                    //printD(me.toString());
                    if (s.key == me['id']) {
                      //shiftX = - (s.value['ship']['pos']['x']) + screen11.x / 2;
                      //shiftY = - (s.value['ship']['pos']['y']) + screen11.y / 2;
                      camX = s.value['ship']['pos']['x'];
                      camY = s.value['ship']['pos']['y'];
                    }
                    //Vector2 zoom = Vector2(screen11.x / world11.x, screen11.y / world11.y) * 0.9;
                    //Vector2 ship = Vector2((s.value['ship']['pos']['x'] + shiftX) * zoom.x + screen11.x / 2, (s.value['ship']['pos']['y'] + shiftY) * zoom.y + screen11.y / 2);
                    //printD('ships draw at $ship with zoom $zoom');
                    return Positioned(
                      left: (s.value['ship']['pos']['x'] - camX) * zoomZ + screenCX,//ship.x,
                      top: (s.value['ship']['pos']['y'] - camY) * zoomZ + screenCY,//ship.y,
                      child: drawShip(s)
                    );}
                  )
                ],
              ),
            ),
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
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white
        //ship['radius'] * screen11.x / world11.x,
        //color: ship['team'] < 0 ? Colors.blue : Colors.red
      ),
    );
  }
  
  void sendMoveToCommand() {
    Offset moveTo = Offset(lastTapDown.dx * (world11.x / screen11.x), lastTapDown.dy * (world11.y / screen11.y));
    final Map<String, dynamic> command = {'category': 'battle', 'type': 'command', 'command': 'move_to', 'data': {'x': moveTo.dx, 'y': moveTo.dy}};
    
    SocketService().send(command);
  }
}