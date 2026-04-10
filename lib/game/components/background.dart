import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../runner_game.dart';

class Background extends SpriteComponent with HasGameRef<RunnerGame> {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('obstacle_tree.png'); // 建议改成真正的背景图
    size = gameRef.size;
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    position.x -= gameRef.speed * dt * 0.2;
    if (position.x < -size.x / 2) position.x = 0;
  }
}