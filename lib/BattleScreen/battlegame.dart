import 'package:eturn/BattleScreen/Flame%20BattleWorld/ShipComponent.dart';
import 'package:eturn/funcs.dart';
import 'package:flame/game.dart';

class BattleGame extends FlameGame {
  final Map<int, ShipComponent> ships = {};

  void applySnapshot(Map<String, dynamic> data) {
    for (final s in data['ships']) {
      final id = s['ship']['id'];
      printD('shipComponentID: $id');
      ships.putIfAbsent(
        id,
        () {
          final ship = ShipComponent(
            teamId: data['team'],
          );
          add(ship);
          return ship;
        },
      );

      ships[id]!
        ..position = Vector2(data['pos']['x'], data['pos']['y'])
        //..hp = s['hp']
        ..alive = true;
    }
  }
}
