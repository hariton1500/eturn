import 'dart:convert';

import 'package:eturn/Screens/lobby.dart';
import 'package:eturn/Screens/tournamentroom.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';

class ShipScreen extends StatefulWidget {
  const ShipScreen({super.key, required this.ship});
  final Map<String, dynamic> ship;
  @override
  State<ShipScreen> createState() => _ShipScreenState();
}

class _ShipScreenState extends State<ShipScreen> {

  Map<String, dynamic> fit = {}, shipDB ={};
  List<Map<String, dynamic>> modules = [];
  int? draggingModuleId;

  @override
  void initState() {
    super.initState();
    loadFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shipDB['name'] ?? ''),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 30,
            children: [
              //Text(widget.ship.toString()),
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ...modules.map((m) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 10,
                        children: [
                          Text(m['name'].toString()),
                          picture(m['id'])
                        ],
                      ))
                    ],
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('High slots:'),
                          if (fit['high'] != null)...showHigh(),
                        ],
                      ),
                      Row(
                        spacing: 7,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Medium slots:'),
                          if (fit['med'] != null)...showMed(),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Low slots:'),
                          if (fit['low'] != null)...showLow(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  SocketService().send({'category': 'lobby', 'type': 'entered_to_lobby', 'ship_id': shipDB['id']});
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LobbyScreen(playerShip: widget.ship, shipModel: shipDB)),(Route<dynamic> route) => false);
                },
                child: Text('Go to Random Battle...'),
              ),
              ElevatedButton(
                onPressed: () {
                  SocketService().send({'category': 'tournament_room', 'type': 'entered_to_tournament_room', 'ship_id': shipDB['id']});
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TournamentRoomScreen()));
                },
                child: Text('Go to Tournaments Battle...'),
              ),
            ]
          ),
        )
      ),
    );
  }
  
  void loadFromDB() async {
    printD('Loading from DB for player_ship ${widget.ship}');
    modules = await sb.from('modules').select();
    printD('loaded modules:\n$modules');
    final shipDBData = await sb.from('ships').select().eq('id', widget.ship['ship_id']);
    if (shipDBData.isNotEmpty) {
      shipDB = shipDBData.first;
    }
    printD('loaded ship data: $shipDB');
    printD('get fit for ship ${widget.ship}');
    fit = await sb.from('players_fits').select().eq('players_ship_id', widget.ship['id']).limit(1).single();
    printD('loaded fit data: $fit');
    printD('fit[high] = ${fit['high']}');
    setState(() {});
  }

  void save() async {
    printD('updating player ships fit ${widget.ship}');
    final res = await sb.from('players_fits').update({'high': fit['high'], 'med': fit['med'], 'low': fit['low']}).eq('id', fit['id']).select();
    printD('result:\n$res');
  }

  List<Widget> showHigh() {
    /*
    table players_fits (
      id bigint,
      created_at timestamp,
      players_ship_id bigint,
      low json  default '{}'::json,
      med json  default '{}'::json,
      high json  default '{}'::json,
      foreign KEY (players_ship_id) references players_ships (id) on update CASCADE on delete CASCADE
    ) TABLESPACE pg_default;
    */
    printD('[render] draw ship:\n$shipDB');
    //if (fit['high'] == null) fit['high'] = '{}';
    printD('[render]show ${shipDB['high']} high slots with ${fit['high']}');
    //var decodedSlots = jsonDecode(fit['high']) as Map<String, dynamic>;
    //printD('[render]decoded high slots:\n$decodedSlots');
    return List.generate(
      shipDB['high'],
      (i) =>
      DragTarget<int>(
        builder: (context, candidateItems, rejectedItems) {
          //int? moduleId = draggingModuleId;
          printD('[render]show place $i with module ${fit['high']?['$i'].toString()}');
          //printD('[render]candidates:\n$candidateItems');
          return fit['high']?['$i'] != null ? picture(fit['high']['$i']) : emptySlot();
        },
        //details is module index of all modules list
        onWillAcceptWithDetails: (details) {
          printD('[render] onWillAcceptWithDetails: ${details.data}');
          //return true if this module type for high slot
          final id = details.data;
          return modules.firstWhere((m) => m['id'] == id)['slot'] == 'high';
        },
        onAcceptWithDetails: (details) {
          //List<int> high = fit['high']!;
          //high[i] = details.data;
          //fit['high'] = jsonEncode(decodedSlots);
          printD('[render]droped module id ${details.data} on high module index $i');
          printD('[render]current fit["high"] is ${fit['high']} and it is type ${fit['high'].runtimeType}');
          if (fit['high'] == null) fit['high'] = <Map<String, dynamic>>{};
          printD('now fit["high"] = ${fit['high']}');
          setState(() {
            fit['high']['$i'] = details.data;
          });
          save();
        },
      )
    );
  }

  List<Widget> showMed() {
    return List.filled(shipDB['med'], Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }

  List<Widget> showLow() {
    return List.filled(shipDB['low'], Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }
  
  Widget picture(int id) {
    Widget pic = Container(
      decoration: BoxDecoration(
        border: Border.all()
      ),
      width: 30,
      height: 30,
      child: Center(child: Text(id.toString())),
    );
    return Draggable<int>(
      onDragStarted: () {
        draggingModuleId = id;
      },
      feedback: Material(child: pic),
      data: id,
      childWhenDragging: pic,
      child: pic,
    );

  }
  
  Widget emptySlot() {
    return Container(width: 30, height: 30,
      decoration: BoxDecoration(border: Border.all(width: 1,)),
    );
  }
}