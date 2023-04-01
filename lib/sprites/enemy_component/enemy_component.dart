import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test_app/character/player.dart';
import 'package:test_app/flame_layer/my_game.dart';
import 'package:test_app/sprites/box_component/box_component.dart';

class EnemyComponent extends SpriteComponent with HasGameRef<MyGame> {
  int _enemyHealth = 100;
  double _enemySpeed = 50;

  EnemyComponent({required Vector2 position}) {
    debugMode = true;
    this.position = position;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    final spriteSize = Vector2(32.0, 32.0);
    size = spriteSize;
    angle = 0;
    anchor = Anchor.center;
    sprite = await gameRef.loadSprite('player.png', srcSize: Vector2(512, 512));
  }

  @override
  void update(double dt) {
    super.update(dt);
    var playerPosition = gameRef.player.position;
    position =
        position + (playerPosition - position).normalized() * _enemySpeed * dt;
    // print('enemy position: $position');
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print("COLLIIIISION");
    // enemy when collides with another EnemyComponent should stop moving in that direction
    if (other is EnemyComponent || other is BoxComponent || other is Player) {
      // stop moving
      _enemySpeed = 0;
    }
  }
}
