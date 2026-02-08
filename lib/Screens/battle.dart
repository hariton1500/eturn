import 'dart:async';

import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/socket.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
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
  double rollZoom = 1;
  Offset lastTapDown = Offset.zero, zoom = Offset(1, 1);
  double zoomZ = 800 / 200000, camX = 0, camY = 0, screenCX = 0, screenCY = 0;


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
    zoomZ = MediaQuery.of(context).size.width / 200000 * rollZoom;
    var myShip = ships.entries.firstWhere((element) => element.key == me['id'], orElse: () => MapEntry(0, {}),);
    if (myShip.value.isNotEmpty) {
      camX = myShip.value['ship']['pos']['x'];
      camY = myShip.value['ship']['pos']['y'];
    }
    printD(lastTapDown.toString());
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        toolbarHeight: 100,
        title: Text('$me ${camX + (lastTapDown.dx - screenCX) / zoomZ} ${camY + (lastTapDown.dy - screenCY) / zoomZ}'),
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
              lastTapDown = details.localPosition;
            },
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  printD(event.scrollDelta.dy.toString());
                  setState(() {
                    if (event.scrollDelta.dy < 0) {
                      rollZoom *= event.scrollDelta.dy.abs() / 2;
                    } else {
                      rollZoom /= event.scrollDelta.dy.abs() / 2;
                    }
                  });
                }
              },
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    ...ships.entries.map((s) {
                      double shipX = s.value['ship']['pos']['x'];
                      double shipY = s.value['ship']['pos']['y'];
                      int shipRadius = s.value['ship_DB']['radius'];
                      //printD(s.toString());
                      //printD((s.value['ship']['pos']['x'] * screen11.x / world11.x).toString());
                      //printD(me.toString());
                      /*
                      if (s.key == me['id']) {
                        camX = shipX;
                        camY = shipY;
                      }*/
                      //printD('ships draw at $ship with zoom $zoom');
                      return Positioned(
                        left: (shipX - camX) * zoomZ + screenCX - shipRadius * zoomZ / 3.9,//ship.x,
                        top: (shipY - camY) * zoomZ + screenCY - shipRadius * zoomZ / 3.9,//ship.y,
                        child: drawShip(s)
                      );}
                    )
                  ],
                ),
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
        ships[id] = player;
      });
    }
  }
  
  Widget drawShip(MapEntry<int, Map<String, dynamic>> s) {
    //final id = s.key;
    //final ship = s.value;
    int shipRadius = s.value['ship_DB']['radius'];
    return Container(
      width: 10,//shipRadius * zoomZ,
      height: 10,//shipRadius * zoomZ,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white
        //ship['radius'] * screen11.x / world11.x,
        //color: ship['team'] < 0 ? Colors.blue : Colors.red
      ),
    );
  }
  
  void sendMoveToCommand() {
    Offset moveTo = Offset(camX + (lastTapDown.dx - screenCX) / zoomZ, camY + (lastTapDown.dy - screenCY) / zoomZ);
    final Map<String, dynamic> command = {'category': 'battle', 'type': 'command', 'command': 'move_to', 'data': {'x': moveTo.dx, 'y': moveTo.dy}};
    
    SocketService().send(command);
  }
}