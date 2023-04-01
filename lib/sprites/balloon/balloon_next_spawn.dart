import 'dart:math';

import 'package:flame/components.dart';
import 'package:test_app/sprites/balloon/balloon.dart';

class BalloonNextSpawn {
  List<Vector2> balloonsPositions = [];
  int lastSpawnPosition = 0;
  int lastSpawnColor = 0;
  final int balloonsCount;

  BalloonNextSpawn({
    required double gameScreenHeight,
    required this.balloonsCount,
    required double padding,
    required double balloonSize,
  }) {
    double gameScreenHeightWithPadding = gameScreenHeight - (2 * padding);
    double spawnableArea = gameScreenHeightWithPadding - balloonSize;

    for (int i = 0; i < balloonsCount; i++) {
      Vector2 randomVector =
          Vector2.random(Random(DateTime.now().microsecondsSinceEpoch));
      Vector2 randomPosition = (randomVector * spawnableArea);
      randomPosition = Vector2(randomPosition.x + padding + balloonSize / 2,
          randomPosition.y + padding + balloonSize / 2);
      balloonsPositions.add(randomPosition);
    }
  }

  Vector2 getNextSpawnPosition() {
    if (lastSpawnPosition == balloonsPositions.length - 1) {
      lastSpawnPosition = 0;
    } else {
      lastSpawnPosition++;
    }
    return balloonsPositions[lastSpawnPosition];
  }

  BalloonColors getNextSpawnColor() {
    List<BalloonColors> balloonColors = BalloonColors.values;
    if (lastSpawnColor == balloonColors.length - 1) {
      lastSpawnColor = 0;
    } else {
      lastSpawnColor++;
    }
    return balloonColors[lastSpawnColor];
  }
}
