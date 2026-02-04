import 'dart:async';

import 'package:eturn/Screens/station.dart';
import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
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
  List<Map<String, dynamic>> lobbyState = [], classes = [];

  @override
  void initState() {
    super.initState();

    sub = SocketService().stream.listen((event) {
      printD('recieved from server:\n$event');
      if (event['category'] == 'lobby' && event['type'] == 'state') {
        List<dynamic> data = event['data']['players_in_lobby'];
        if (data.isNotEmpty) {
          for (var element in data) {
            printD(element.toString());
            printD(element.runtimeType.toString());
            lobbyState.add(element as Map<String, dynamic>);
          }
          setState(() {});
        } 
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
      appBar: AppBar(
        title: Text('Lobby'),
        actions: [
          ElevatedButton(onPressed: () {
            //send leave lobby command to server
            SocketService().send({'category': 'lobby', 'type': 'leave_lobby'});
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => StationScreen()),(Route<dynamic> route) => false);
          },
          child: Text('Leave lobby'))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                //showPlayersInLobby(),
                showByClass()
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
  
  Widget showByClass() {
    return Column(
      spacing: 10,
      children: [
        if (classes.isNotEmpty) ...classes.map((cl) {
          final i = lobbyState.where((s) => s['ship_class']['name'] == cl['name']).length;
          return i > 0 ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(cl['name']),
              Text(i.toString())
            ],
          ) : Text('');
        })
      ],
    );
  }
  Widget showPlayersInLobby() {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        if (lobbyState.isNotEmpty) ...lobbyState.map((player) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Text(player['ship_DB']['name'].toString()),
            Text(player['ship_class']['name'].toString())
          ],
        ))
      ],
    );
  }
  
  void loadFromDB() async {
    classes = await sb.from('ship_classes').select();
    setState(() {});
  }
}