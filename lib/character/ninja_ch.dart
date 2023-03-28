import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:test_app/character/character.dart';
import 'package:test_app/flame_layer/my_game.dart';

class Ninja extends SpriteComponent with HasGameRef<MyGame> {
  Ninja() {
    debugMode = true;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    Character character = Character(x: 200, y: 300, width: 16, height: 16);
    final spriteSize = Vector2(32.0, 32.0);
    size = spriteSize;
    position = Vector2(character.x, character.y);
    sprite = await gameRef.loadSprite('character_idle.png',
        srcSize: Vector2(16, 16));
  }

  @override
  void update(double dt) {
    if (sprite == null) return;

    super.update(dt);
    position.add(gameRef.joystick.delta * dt * 100);
  }
}
