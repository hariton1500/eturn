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

  List<Map<String, dynamic>> types = [], ships = [], myShips = [];
  
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
                          setState(() {
                            myShips.add(addingShip);
                          });
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
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShipScreen(ship: ship)));
                    },
                    child: Text(ship['name']
                  )))
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

    printD('requesting my ships for player ${me?.id}');
    myShips = await sb.from('players_ships').select().eq('player_id', me!.id);

    setState(() {
      
    });
  }
}