import 'dart:convert';

import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:flutter/material.dart';

class ShipScreen extends StatefulWidget {
  const ShipScreen({super.key, required this.ship});
  final Map<String, dynamic> ship;
  @override
  State<ShipScreen> createState() => _ShipScreenState();
}

class _ShipScreenState extends State<ShipScreen> {

  Map<String, dynamic> fit = {}, ship = {'high': 0, 'med': 0, 'low': 0};
  List<Map<String, dynamic>> modules = [];
  int? draggingModuleId;

  @override
  void initState() {
    super.initState();
    //fit['high'] = List.filled(widget.ship['high'], -1);
    //fit['med'] = List.filled(widget.ship['med'], -1);
    //fit['low'] = List.filled(widget.ship['low'], -1);
    loadFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ship['name'].toString()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          ...showHigh(),
                        ],
                      ),
                      Row(
                        spacing: 7,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Medium slots:'),
                          ...showMed(),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Low slots:'),
                          ...showLow(),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ]
          ),
        )
      ),
    );
  }
  
  void loadFromDB() async {
    printD('Loading from DB for player_ship ${widget.ship}');
    modules = await sb.from('modules').select();
    printD(modules.toString());
    final shipDB = await sb.from('ships').select().eq('id', widget.ship['ship_id']);
    if (shipDB.isNotEmpty) {
      ship = shipDB.first;
    }
    final fits = await sb.from('players_fits').select().eq('players_ship_id', widget.ship['id']);
    if (fits.isNotEmpty) {
      fit = fits.first;
    }
    setState(() {
      
    });
  }

  void save() {
    printD('updating player ship ${widget.ship['id']}');
    sb.from('players_ships').update({'fit': fit}).eq('id', widget.ship['id']).select().then(print);
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
    printD('ship:\n$ship');
    if (fit['high'] == null) fit['high'] = '{}';
    printD('show high slots with ${fit['high']}');
    var decodedSlots = jsonDecode(fit['high']) as Map<String, dynamic>;
    printD('decoded high slots:\n$decodedSlots');
    return List.generate(
      ship['high'],
      (i) =>
      DragTarget<int>(
        builder: (context, candidateItems, rejectedItems) {
          //int? moduleId = draggingModuleId;
          printD('show place $i with module id $draggingModuleId');
          printD('candidates:\n$candidateItems');
          return draggingModuleId != null ? picture(draggingModuleId!) : emptySlot();
        },
        //details is module index of all modules list
        onWillAcceptWithDetails: (details) {
          printD(details.data.toString());
          //return true if this module type for high slot
          final id = details.data;
          return modules.firstWhere((m) => m['id'] == id)['slot'] == 'high';
        },
        onAcceptWithDetails: (details) {
          //List<int> high = fit['high']!;
          //high[i] = details.data;
          decodedSlots['$i'] = details;
          fit['high'] = jsonEncode(decodedSlots);
          save();
          setState(() {
            //fit['high'] = high;
          });
        },
      )
    );
  }

  List<Widget> showMed() {
    return List.filled(ship['med'], Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }

  List<Widget> showLow() {
    return List.filled(ship['low'], Container(width: 30, height: 30,
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