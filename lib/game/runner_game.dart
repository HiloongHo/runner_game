import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import 'components/background.dart';
import 'components/ground.dart';
import 'components/player.dart';
import 'components/obstacle.dart';
import 'components/obstacle_spawner.dart';
import 'components/game_over_text.dart';

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
