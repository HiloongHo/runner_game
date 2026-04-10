import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';

class Obstacle extends SpriteComponent with HasGameRef<RunnerGame> {
  static const List<String> obstacleImages = [
    'obstacle_tree.png',
    'obstacle_cloud.png',
  ];

  Obstacle()
      : super(
    size: Vector2(50, 60),
    anchor: Anchor.bottomLeft,
  );

  @override
  Future<void> onLoad() async {
    final randomImage = obstacleImages[
    DateTime.now().millisecondsSinceEpoch % obstacleImages.length];
    sprite = await Sprite.load(randomImage);

    position = Vector2(gameRef.size.x + 50, gameRef.size.y - 80);

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= gameRef.speed * dt;
    if (position.x < -100) removeFromParent();
  }
}