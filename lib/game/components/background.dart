import 'package:flame/components.dart';
import '../runner_game.dart';

class Background extends SpriteComponent with HasGameReference<RunnerGame> {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('obstacle_tree.png');
    size = game.size;                    // ← gameRef → game
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    position.x -= game.speed * dt * 0.2; // ← gameRef → game
    if (position.x < -size.x / 2) position.x = 0;
  }
}