import 'package:eturn/BattleScreen/Flame%20BattleWorld/ShipComponent.dart';
import 'package:flame/game.dart';

class BattleGame extends FlameGame {
  final Map<int, ShipComponent> ships = {};

  void applySnapshot(Map<String, dynamic> snap) {
    for (final s in snap['ships']) {
      final id = s['id'];

      ships.putIfAbsent(
        id,
        () {
          final ship = ShipComponent(
            teamId: s['teamId'],
          );
          add(ship);
          return ship;
        },
      );

      ships[id]!
        ..position = Vector2(s['x'] * 20, s['y'] * 20)
        ..hp = s['hp']
        ..alive = s['alive'];
    }
  }
}
