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
  List<Map<int, String>> myShips = [];
  
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
                          //send to server add ship to hangar
                          //sending();
                          var addingShip = (await sb.from('ships').select().eq('class_id', t['id']).eq('fraction_id', widget.f['id'])).first;
                          printD('adding $addingShip to hangar');
                          printD('adding new ship to DB');
                          final dbShip = await sb.from('players_ships').insert({'player_id': me?.id, 'ship_id': addingShip['id']}).select();
                          if (dbShip.isNotEmpty) {
                            printD('creating fit for ship = ${dbShip.first}');
                            final newFit = await sb.from('players_fits').insert({'players_ship_id': dbShip.first['id']}).select();
                            if (newFit.isNotEmpty) {
                              printD('created fit $newFit');
                              setState(() {
                                myShips.add({0: dbShip.first['name']});
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
                  ...myShips.map((ship) => ElevatedButton(
                    onPressed: () async {
                      final id = ship.keys.first;
                      final shipDB = await sb.from('players_ships').select().eq('id', id);
                      if (shipDB.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShipScreen(ship: (shipDB.first))));
                      }
                    },
                    child: Text(ship.values.first)
                  ))
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
    final myShipsDB = await sb.from('players_ships').select().eq('player_id', me!.id);
    printD(myShipsDB.toString());
    if (myShipsDB.isNotEmpty) {
      for (var myShipDB in myShipsDB) {
        final shipDB = await sb.from('ships').select().eq('id', myShipDB['ship_id']);
        if (shipDB.isNotEmpty) {
          myShips.add({myShipDB['id']: shipDB.first['name']});
        }
      }
      
    }
    printD(myShips.toString());
    setState(() {
      
    });
  }
}