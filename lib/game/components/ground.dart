import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../runner_game.dart';

class Ground extends RectangleComponent with HasGameReference<RunnerGame> {
  Ground()
      : super(
    size: Vector2(9999, 80),
    paint: Paint()..color = const Color(0xFF8B4513),
  );

  @override
  void onLoad() {
    position = Vector2(0, game.size.y - 80);
  }

  @override
  void update(double dt) {
    position.x -= game.speed * dt * 0.8;
    if (position.x < -1000) position.x = 0;
  }
}