import 'package:flame/components.dart';
import '../runner_game.dart';
import 'obstacle.dart';

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
