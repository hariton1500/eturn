import 'package:eturn/Screens/ship.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:flutter/material.dart';

class FractionScreen extends StatefulWidget {
  const FractionScreen({required this.f, super.key});
  final Map<String, dynamic> f;

  @override
  State<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends State<FractionScreen> {

  List<Map<String, dynamic>> types = [], ships = [];
  List<Map<String, dynamic>> myShips = [];
  
  @override
  void initState() {
    super.initState();
    loadFromDB();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.f.toString()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...types.map((t) => Column(
                    children: [
                      Text(t['name']),
                      ElevatedButton(
                        onPressed: () async {
                          printD('get first ship from fraction id ${widget.f['id']}');
                          var addingShip = (await sb.from('ships').select().eq('class_id', t['id']).eq('fraction_id', widget.f['id'])).first;
                          printD('adding $addingShip to hangar');
                          printD('adding ship id ${addingShip['id']} to players_ships for player id ${me?.id}');
                          final dbShip = await sb.from('players_ships').insert({'player_id': me?.id, 'ship_id': addingShip['id']}).select();
                          if (dbShip.isNotEmpty) {
                            printD('added to players_ships is ${dbShip.first}');
                            printD('adding fit for players_ship_id ${dbShip.first['id']}');
                            final newFit = await sb.from('players_fits').insert({'players_ship_id': dbShip.first['id']}).select();
                            if (newFit.isNotEmpty) {
                              printD('created fit ${newFit.first}');
                              setState(() {
                                myShips.add(addingShip);
                              });
                            }
                          }
                        },
                        child: Text('add to hangar')
                      )
                    ],
                  ))
                ],
              ),
              SizedBox(height: 100,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...myShips.map((ship) {
                    printD('get ship data from ships for ship id ${ship['ship_id']}');
                    final shipDB = sb.from('ships').select().eq('id', ship['ship_id']);
                    return FutureBuilder(
                      future: shipDB,
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          return ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShipScreen(ship: (ship))));
                            },
                            child: Text(asyncSnapshot.data!.first['name'].toString())
                          );
                        } else {
                          return Text('');
                        }
                      }
                    );
                  })
                ],
              )
            ],
          ),
        )
      ),
    );
  }
  
  void loadFromDB() async {
    printD('requesting ship_types for player ${me?.id}');
    types = await sb.from('ship_types').select();
    printD(types.toString());

    printD('requesting my ships for player ${me?.id}');
    myShips = await sb.from('players_ships').select().eq('player_id', me!.id);
    printD(myShips.toString());
    /*
    if (myShips.isNotEmpty) {
      for (var myShipDB in myShips) {
        final shipDB = await sb.from('ships').select().eq('id', myShipDB['ship_id']);
        if (shipDB.isNotEmpty) {
          myShips.add({myShipDB['id']: shipDB.first['name']});
        }
      }
    }
    printD(myShips.toString());*/
    setState(() {});
  }
}