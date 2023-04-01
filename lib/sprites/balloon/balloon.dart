import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test_app/flame_layer/balloon_wars.dart';

enum BalloonColors { blue, green, pink, purple, red, yellow }

class Balloon extends SpriteComponent with HasGameRef<BalloonWars> {
  static const double splitAngle = 0;
  static const double maxSize = 50;
  final BalloonColors balloonColor;
  final bool isPlayer;

  Balloon(
      {required this.balloonColor,
      this.isPlayer = false,
      required Vector2 position}) {
    debugMode = true;
    this.position = position;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    final spriteSize = Vector2(maxSize, maxSize);
    size = spriteSize;
    angle = 0;
    anchor = Anchor.center;
    String color = balloonColor.toString().split('.').last;
    sprite = await gameRef.loadSprite('$color.png', srcSize: Vector2(512, 512));
  }

  @override
  void update(double dt) {
    if (sprite == null) return;

    super.update(dt);
    if (isPlayer) {
      position.add(gameRef.joystick.delta * dt * 5);
      if (gameRef.joystick.delta != Vector2.zero()) {
        var angleDeg =
            atan2(gameRef.joystick.delta.y, gameRef.joystick.delta.x);
        angle = angleDeg - pi / 2 + splitAngle;
      }
    }
  }
}
