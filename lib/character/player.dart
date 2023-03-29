import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test_app/character/character.dart';
import 'package:test_app/flame_layer/my_game.dart';

class Player extends SpriteComponent with HasGameRef<MyGame> {
  static const double splitAngle = pi / 4;
  Player() {
    debugMode = true;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    Character character = Character(x: 200, y: 300, width: 32, height: 32);
    final spriteSize = Vector2(32.0, 32.0);
    size = spriteSize;
    position = Vector2(character.x, character.y);
    angle = 0;
    anchor = Anchor.center;
    sprite = await gameRef.loadSprite('player.png', srcSize: Vector2(512, 512));
  }

  @override
  void update(double dt) {
    if (sprite == null) return;

    super.update(dt);
    position.add(gameRef.joystick.delta * dt * 5);
    if (gameRef.joystick.delta != Vector2.zero()) {
      var angleDeg = atan2(gameRef.joystick.delta.y, gameRef.joystick.delta.x);
      angle = angleDeg - pi / 2 + splitAngle;
    }
  }
}
