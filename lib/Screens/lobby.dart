import 'dart:async';

import 'package:eturn/BattleScreen/battlescreen.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/models/socket.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, required Map<String, dynamic> playerShip, required Map<String, dynamic> shipModel});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {

  late StreamSubscription sub;
  Map<String, dynamic> sending = {'category': 'lobby'};

  //    'ship_DB': shipDB,
  //    'ship_class': shipClass
  List<Map<String, dynamic>> lobbyState = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();

    sub = SocketService().stream.listen((event) {
      printD('recieved from server:\n$event');
      if (event['category'] == 'lobby' && event['type'] == 'state') {
        setState(() {
          lobbyState = event['data'];
        });
      }
    });

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
      appBar: AppBar(
        title: Text('Lobby'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                showPlayersInLobby()
              ],
            ),
          ),
        )
      ),
    );
  }
  
  void handleLobbyIncomeMessages(Map<String, dynamic> msg, WebSocketChannel channel) {
    try {
      switch (msg['type']) {
        case 'lobby_state':
          final locked = msg['locked'];
          //players.clear();
          //players.addAll((msg['players'] as List).map((e) => {'id': e['id'], 'ready': e['ready']}));// = msg['players'] as Map<String, dynamic>;
          setState(() {
            
          });
          break;
        case 'lobby_connected':
          setState(() {
            //isConnectedToLobby = true;
          });
        case 'startBattle':
          //streamSubscription.cancel();
          //streamSubscription.onData(handleData)
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BattleScreen(streamSubscription: streamSubscription, channel: channel,)));
        default:
      }
    } catch (e) {
      print(e);
    }
  }
  
  Widget showPlayersInLobby() {
    return Column(
      children: [
        ...lobbyState.map((player) => Row(
          children: [
            Text(player['ship_DB']),
            Text(player['ship_class'])
          ],
        ))
      ],
    );
  }
}