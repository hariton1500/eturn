import 'dart:async';
import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';

class StationScreen extends StatefulWidget {
  const StationScreen({super.key});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {

  late StreamSubscription sub;
  Map<String, dynamic> sending = {'category': 'station'};
  List<Map<String, dynamic>> state = [], fractions = [], playerShips = [];

  @override
  void initState() {
    super.initState();

    sub = SocketService().stream.listen((event) {
      if (event['category'] == 'station' && event['type'] == 'state') {
        loadFromDB(event['data']);
      }
    });

    

    //sending data request
    sending['type'] = 'get_state';
    SocketService().send(sending);
  }

  @override
  void dispose() {
    sub.cancel(); // 🔥 ОБЯЗАТЕЛЬНО
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text('Money: 0 isk'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...fractions.map((f) => Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(
                        color: Colors.black
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(f['name']),
                    )
                  )),
                  //if ((state.firstWhere((s) => s['fraction_id'] == f['id'])).isNotEmpty) ElevatedButton(onPressed: () {}, child: Text('Take First Ship'))
                ],
              ),
              showHangar()
            ],
          ),
        )
      ),
    );
  }

  void loadFromDB(Map<String, dynamic> data) async {
    //load fractions list
    printD('requesting fraction');
    List<Map<String, dynamic>> fractionRequest = await sb.from('fractions').select();
    printD(fractionRequest.toString());
    setState(() {
      fractions = fractionRequest;
    });

    printD('requesting players_progress');
    List<Map<String, dynamic>> request = await sb.from('players_progress').select().eq('email', data['player_id']);
    printD(request.toString());
    if (request.isNotEmpty) {
      setState(() {
        state = request;
      });
    }

    printD('requesting player_ships for player ${data['player_id']}');
    List<Map<String, dynamic>> playerShipsRequest = await sb.from('player_ships').select().eq('email', data['player_id']);
    printD(playerShipsRequest.toString());
    setState(() {
      playerShips = playerShipsRequest;
    });


  }
  
  Widget showHangar() {
    return Wrap(
      children: [
        ...playerShips.map((ship) => Text(ship['ship_id']))
      ],
    );
  }
}