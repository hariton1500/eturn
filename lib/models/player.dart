import 'package:eturn/globals.dart';

enum Categories {
  justLoggedIn,
  station
}

class Player {
  final int id;
  //final WebSocket socket;

  Categories category = Categories.justLoggedIn; 
  String? teamId;
  bool ready = false;
  Map<String, dynamic> playerProgress = {};

  Player({
    required this.id,
  });

  Future<void> loadFromDB() async {
    var temp = await sb.from('player_progress').select().limit(1);
    playerProgress = temp.first;
  }

  @override
  String toString() {
    return '$id; $category';
  }
}
