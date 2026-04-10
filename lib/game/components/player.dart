import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../audio/flame_audio.dart';
import '../models/player_state.dart';
import '../runner_game.dart';
import 'obstacle.dart';

class Player extends SpriteAnimationGroupComponent<PlayerState> with CollisionCallbacks, HasGameRef<RunnerGame> {
  final double gravity = 980;
  final double jumpSpeed = -480;
  double velocityY = 0;
  bool isOnGround = true;
  int jumpCount = 0;
  late double groundY;

  Player() : super(size: Vector2(80, 100), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    groundY = gameRef.size.y - 80;
    position = Vector2(100, groundY);

    final runFrames = await Future.wait(List.generate(10, (i) => Sprite.load('run_${i + 1}.png')));
    final jumpFrames = await Future.wait(List.generate(10, (i) => Sprite.load('jump_${i + 1}.png')));
    final slideFrames = await Future.wait(List.generate(10, (i) => Sprite.load('slide_${i + 1}.png')));
    final deathFrames = await Future.wait(List.generate(10, (i) => Sprite.load('death_${i + 1}.png')));

    animations = {
      PlayerState.run: SpriteAnimation.spriteList(runFrames, stepTime: 0.05, loop: true),
      PlayerState.jump: SpriteAnimation.spriteList(jumpFrames, stepTime: 0.08, loop: false),
      PlayerState.slide: SpriteAnimation.spriteList(slideFrames, stepTime: 0.08, loop: true),
      PlayerState.death: SpriteAnimation.spriteList(deathFrames, stepTime: 0.1, loop: false),
    };

    current = PlayerState.run;

    add(RectangleHitbox());
  }

  void jump() {
    if (jumpCount < 2) {
      velocityY = jumpSpeed;
      jumpCount++;
      isOnGround = false;
      current = PlayerState.jump;
      AudioManager.playJump();
    }
  }

  void reset() {
    velocityY = 0;
    jumpCount = 0;
    isOnGround = true;
    position.y = groundY;
    current = PlayerState.run;
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (position.y >= groundY) {
      position.y = groundY;
      velocityY = 0;
      isOnGround = true;
      jumpCount = 0;
      current = PlayerState.run;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Obstacle) {
      current = PlayerState.death;
      gameRef.gameOver();
    }
  }
}
