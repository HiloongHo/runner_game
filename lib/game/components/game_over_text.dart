import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../runner_game.dart';

class GameOverText extends Component with HasGameReference<RunnerGame> {
  @override
  void onLoad() {
    final text = TextComponent(
      text: '游戏结束\n\n分数: ${game.score}\n点击屏幕重新开始',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    text.position = game.size / 2;
    add(text);
  }
}