import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test_app/flame_layer/balloon_wars.dart';

class Bubble extends SpriteComponent with HasGameRef<BalloonWars> {
  final double _speed = 450;
  late Vector2 directionVector;
  final Vector2 bulletSize = Vector2(16, 16);
  static const double bubbleSize = 20;

  Bubble({
    required Vector2 center,
    required angle,
  }) {
    debugMode = true;
    this.angle = angle;
    directionVector = Vector2(1, 0);
    directionVector.rotate(angle);
    this.center = center;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    final spriteSize = Vector2(bubbleSize, bubbleSize);
    size = spriteSize;
    angle = 0;
    anchor = Anchor.center;
    sprite = await gameRef.loadSprite('bubble.png', srcSize: Vector2(512, 512));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // get vecrot from angle gameRef.player.angle
    position.add(directionVector * _speed * dt);
    if (position.y > gameRef.gameScreenHeight ||
        position.x > gameRef.gameScreenHeight ||
        position.y < 0 ||
        position.x < 0) {
      removeFromParent();
    }
  }
}
