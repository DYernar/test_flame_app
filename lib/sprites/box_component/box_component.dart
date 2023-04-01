import 'package:flame/components.dart';

class BoxComponent extends SpriteComponent {
  BoxComponent({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        );
}
