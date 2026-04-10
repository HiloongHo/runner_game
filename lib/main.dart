import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(GameWidget(game: RunnerGame()));
}

class RunnerGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Player player;
  late TextComponent scoreText;
  int score = 0;
  bool isGameOver = false;
  double speed = 250;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(Background());
    add(Ground());

    player = Player();
    add(player);

    scoreText = TextComponent(
      text: '分数: 0',
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 32)),
      position: Vector2(20, 20),
    );
    add(scoreText);

    add(ObstacleSpawner());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameOver) {
      score += (dt * 60).toInt();
      scoreText.text = '分数: $score';
      speed = 250 + (score / 80); // 越跑越快
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isGameOver) {
      player.jump();
    } else {
      restartGame();
    }
  }

  void gameOver() {
    isGameOver = true;
    add(GameOverText());
  }

  void restartGame() {
    removeWhere((c) => c is Obstacle || c is GameOverText);
    score = 0;
    speed = 250;
    isGameOver = false;
    player.reset();
  }
}

// ==================== 背景 ====================
class Background extends Component with HasGameRef<RunnerGame> {
  @override
  void render(Canvas canvas) {
    final rect = gameRef.size.toRect();
    canvas.drawRect(rect, Paint()..color = const Color(0xFF87CEEB));
  }
}

// ==================== 地面 ====================
class Ground extends RectangleComponent with HasGameRef<RunnerGame> {
  Ground() : super(
    size: Vector2(9999, 80),
    paint: Paint()..color = const Color(0xFF8B4513),
  );

  @override
  void onLoad() {
    position = Vector2(0, gameRef.size.y - 80);
  }

  @override
  void update(double dt) {
    position.x -= gameRef.speed * dt * 0.8;
    if (position.x < -1000) position.x = 0;
  }
}

// ==================== 玩家 ====================
enum PlayerState { run, jump, slide, death }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<RunnerGame> {
  final double gravity = 980;
  final double jumpSpeed = -480;
  double velocityY = 0;
  bool isOnGround = true;
  int jumpCount = 0;
  late double groundY;

  Player() : super(
    size: Vector2(80, 100),        // 根据你的Temple Run图片大小微调（建议80x100左右）
    anchor: Anchor.bottomLeft,
  );

  @override
  Future<void> onLoad() async {
    groundY = gameRef.size.y - 80;
    position = Vector2(100, groundY);

    // 加载所有动画（10帧每秒0.05秒一帧）
    final runFrames = await Future.wait(
      List.generate(10, (i) => Sprite.load('run_${i + 1}.png')),
    );
    final jumpFrames = await Future.wait(
      List.generate(10, (i) => Sprite.load('jump_${i + 1}.png')),
    );
    final slideFrames = await Future.wait(
      List.generate(10, (i) => Sprite.load('slide_${i + 1}.png')),
    );
    final deathFrames = await Future.wait(
      List.generate(10, (i) => Sprite.load('death_${i + 1}.png')),
    );

    animations = {
      PlayerState.run: SpriteAnimation.spriteList(runFrames, stepTime: 0.05, loop: true),
      PlayerState.jump: SpriteAnimation.spriteList(jumpFrames, stepTime: 0.08, loop: false),
      PlayerState.slide: SpriteAnimation.spriteList(slideFrames, stepTime: 0.08, loop: true),
      PlayerState.death: SpriteAnimation.spriteList(deathFrames, stepTime: 0.1, loop: false),
    };

    current = PlayerState.run;   // 默认播放跑步动画

    // 碰撞盒（根据图片大小调整）
    add(RectangleHitbox());
  }

  void jump() {
    if (jumpCount < 2) {
      velocityY = jumpSpeed;
      jumpCount++;
      isOnGround = false;
      current = PlayerState.jump;   // 切换到跳跃动画
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

    // 落地检测
    if (position.y >= groundY) {
      position.y = groundY;
      velocityY = 0;
      isOnGround = true;
      jumpCount = 0;
      current = PlayerState.run;   // 落地后切回跑步动画
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      current = PlayerState.death;
      gameRef.gameOver();
    }
  }
}

// ==================== 障碍物 ====================
class Obstacle extends RectangleComponent with HasGameRef<RunnerGame> {
  Obstacle() : super(
    size: Vector2(40, 60),
    paint: Paint()..color = Colors.red,
  );

  @override
  void onLoad() {
    position = Vector2(gameRef.size.x + 50, gameRef.size.y - 80 - size.y);
  }

  @override
  void update(double dt) {
    position.x -= gameRef.speed * dt;
    if (position.x < -100) removeFromParent();
  }
}

// ==================== 障碍物生成器 ====================
class ObstacleSpawner extends Component with HasGameRef<RunnerGame> {
  double timer = 0;
  final double spawnInterval = 1.6;

  @override
  void update(double dt) {
    timer += dt;
    if (timer > spawnInterval) {
      timer = 0;
      gameRef.add(Obstacle());
    }
  }
}

// ==================== 游戏结束 ====================
class GameOverText extends Component with HasGameRef<RunnerGame> {
  @override
  void onLoad() {
    final text = TextComponent(
      text: '游戏结束\n\n分数: ${gameRef.score}\n点击屏幕重新开始',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    text.position = gameRef.size / 2;
    add(text);
  }
}