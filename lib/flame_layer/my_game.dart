import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:test_app/character/player.dart';
import 'package:test_app/map_generator/box.dart';
import 'package:test_app/map_generator/map_generator.dart';
import 'package:test_app/map_generator/simple_map/simple_map.dart';

class MyGame extends FlameGame with HasCollisionDetection, HasDraggables {
  SpriteComponent background = SpriteComponent();
  late JoystickComponent joystick;
  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    double screenHeight = size[0];
    double screenWidth = size[1];
    double cellSize = screenHeight / 20;

    // set camera
    camera.viewport =
        FixedResolutionViewport(Vector2(screenHeight, screenWidth));

    // load background
    background
      ..sprite = await loadSprite('background.png')
      ..size = Vector2(screenHeight, screenHeight);
    background.setColor(Colors.grey);
    add(background);

    // load bloxes
    MapGenerator map = SimpleMap(screenSize: screenHeight, cellAmount: 20);
    List<Box> boxes = map.generateMap();
    for (Box box in boxes) {
      SpriteComponent boxSprite = SpriteComponent();
      boxSprite
        ..sprite = await loadSprite('box.png')
        ..size = Vector2(box.width, box.width)
        ..position = Vector2(box.x, box.y);
      add(boxSprite);
    }

    // create joystick
    final knobPaint = BasicPalette.white.paint();
    final backgroundPaint = BasicPalette.lightGray.paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    player = Player();
    // camera follow ninja
    camera.followComponent(player, relativeOffset: const Anchor(0.5, 0.5));
    add(player);
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   camera.followComponent(ninja, relativeOffset: const Anchor(0.5, 0.5));
  // }
}
