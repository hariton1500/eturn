import 'dart:async';

import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';

class TournamentRoomScreen extends StatefulWidget {
  const TournamentRoomScreen({super.key});

  @override
  State<TournamentRoomScreen> createState() => _TournamentRoomScreenState();
}

class _TournamentRoomScreenState extends State<TournamentRoomScreen> {

  late StreamSubscription sub;
  Map<String, dynamic> sending = {'category': 'lobby'};

  //    'ship_DB': shipDB,
  //    'ship_class': shipClass
  List<Map<String, dynamic>> roomState = [], classes = [];
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    sub = SocketService().stream.listen((event) {
      printD('recieved from server:\n$event');
      if (event['category'] == 'tournament_room' && event['type'] == 'state') {
        if (event['data']['player_id'] == me?.id) {
          setState(() {
            isReady = event['data']['change_ready'];
          });
        } 
      }
      if (event['category'] == 'tournament_room' && event['type'] == 'change_ready') {

      }
    });

    loadFromDB();

    //sending data request
    //sending['type'] = 'get_state';
    //SocketService().send(sending);
  }

  @override
  void dispose() {
    sub.cancel(); // 🔥 ОБЯЗАТЕЛЬНО
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                if (roomState.isNotEmpty) ...roomState.map((player) => Text(player['ship_DB']['name'].toString())),
                ElevatedButton(onPressed: () {
                  SocketService().send({'category': 'tournament_room', 'type': 'change_ready'});
                },
                child: Text(isReady ? 'Not Ready' : 'Ready!'))
              ],
            ),
          ),
        )
      ),
    );
  }
  
  void loadFromDB() {}
}