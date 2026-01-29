import 'dart:async';
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
  Map<String, dynamic> sending = {'category': 'station'}, state = {};

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
        leading: Text('Money: ${state['money'] ?? 0} isk'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(state.toString()),
        )
      ),
    );
  }

  void loadFromDB(Map<String, dynamic> data) async {
    List<Map<String, dynamic>> request = await sb.from('players_progress').select().eq('player_id', data['player_id']);
    print(request);
    setState(() {
      state = request[0];
    });
  }
}