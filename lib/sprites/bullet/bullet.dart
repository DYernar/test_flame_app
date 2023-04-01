import 'package:flame/components.dart';
import 'package:test_app/flame_layer/my_game.dart';

class Bullet extends SpriteComponent with HasGameRef<MyGame> {
  final double _speed = 450;
  late Vector2 directionVector;
  final Vector2 bulletSize = Vector2(16, 16);

  Bullet({
    required sprite,
    required Vector2 center,
    required angle,
  }) {
    debugMode = true;
    this.sprite = sprite;
    size = bulletSize;
    this.angle = angle;
    // find direction to the bullet
    directionVector = Vector2(1, 0);
    directionVector.rotate(angle);
    this.center = center;
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

  // detect collision with other sprites
}
