import 'package:flame/components.dart';
//import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/material.dart';

class ShipComponent extends PositionComponent {
  final int teamId;
  double hp = 100;
  bool alive = true;

  ShipComponent({required this.teamId})
      : super(size: Vector2.all(20));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = alive
          ? (teamId == 1 ? Colors.blue : Colors.red)
          : Colors.grey;

    canvas.drawCircle(Offset.zero, 10, paint);
  }
}
