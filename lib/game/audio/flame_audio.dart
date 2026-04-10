import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    // 预加载所有音效（SFX）
    await FlameAudio.audioCache.loadAll([
      'jump.mp3',
      'hit.mp3',
    ]);

    // 背景音乐预加载（可选）
    FlameAudio.bgm.initialize();

    _isInitialized = true;
  }

  // 播放跳跃音效
  static void playJump() {
    FlameAudio.play('jump.mp3', volume: 0.8);
  }

  // 播放撞击/死亡音效
  static void playHit() {
    FlameAudio.play('hit.mp3', volume: 1.0);
  }

  // 播放背景音乐（循环）
  static void playBgm() {
    FlameAudio.bgm.play('bgm.mp3', volume: 0.6);
  }

  // 停止背景音乐
  static void stopBgm() {
    FlameAudio.bgm.stop();
  }

  // 暂停/恢复（游戏暂停时可用）
  static void pauseAll() => FlameAudio.bgm.pause();
  static void resumeAll() => FlameAudio.bgm.resume();
}