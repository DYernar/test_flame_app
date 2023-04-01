import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:test_app/map_generator/box_model.dart';
import 'package:test_app/map_generator/map_generator.dart';
import 'package:test_app/map_generator/simple_map/simple_map.dart';
import 'package:test_app/sprites/balloon/balloon.dart';
import 'package:test_app/sprites/balloon/balloon_next_spawn.dart';
import 'package:test_app/sprites/box_component/box_component.dart';
import 'package:test_app/sprites/bubble/bubble.dart';

class BalloonWars extends FlameGame with HasDraggables, TapDetector {
  SpriteComponent background = SpriteComponent();
  late JoystickComponent joystick;
  late BalloonNextSpawn balloonNextSpawner;
  late double gameScreenHeight;
  late double gameScreenWidth;
  late Balloon player;
  final int cellAmount = 20;
  int balloonsCount = 5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameScreenHeight = size[0];
    gameScreenWidth = size[1];
    double cellSize = gameScreenHeight / cellAmount;
    camera.viewport =
        FixedResolutionViewport(Vector2(gameScreenHeight, gameScreenWidth));
    // init balloon spawner
    balloonNextSpawner = BalloonNextSpawn(
      gameScreenHeight: gameScreenHeight,
      balloonsCount: balloonsCount,
      padding: cellSize,
      balloonSize: Balloon.maxSize,
    );
    // load background
    await _addBackground();
    await _addBoxes();
    _addJoystick();
    _addBalloons();
    _addPlayer();
  }

  Future<void> _addBackground() async {
    background
      ..sprite = await loadSprite('background.png')
      ..size = Vector2(gameScreenHeight, gameScreenHeight);
    background.setColor(Colors.grey);
    add(background);
  }

  Future<void> _addBoxes() async {
    MapGenerator map = SimpleMap(screenSize: gameScreenHeight, cellAmount: 20);
    List<BoxModel> boxes = map.generateMap();
    for (BoxModel box in boxes) {
      BoxComponent boxSprite = BoxComponent(
        sprite: await loadSprite('box.png'),
        position: Vector2(box.x, box.y),
        size: Vector2(box.width, box.width),
      );
      add(boxSprite);
    }
  }

  void _addJoystick() {
    final knobPaint = BasicPalette.white.paint();
    final backgroundPaint = BasicPalette.lightGray.paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);
  }

  void _addBalloons() async {
    int currentBalloonAmount = children.whereType<Balloon>().toList().length;
    for (int i = currentBalloonAmount; i < balloonsCount; i++) {
      final Vector2 spawnPosition = balloonNextSpawner.getNextSpawnPosition();
      final BalloonColors spawnColor = balloonNextSpawner.getNextSpawnColor();
      Balloon balloon = Balloon(
        balloonColor: spawnColor,
        position: spawnPosition,
        isPlayer: false,
      );
      add(balloon);
    }
  }

  void _addPlayer() {
    final Vector2 spawnPosition = balloonNextSpawner.getNextSpawnPosition();
    player = Balloon(
      balloonColor: BalloonColors.red,
      position: spawnPosition,
      isPlayer: true,
    );
    camera.followComponent(player, relativeOffset: const Anchor(0.5, 0.5));
    add(player);
  }

  bool isPlayerAlive() {
    return children
        .whereType<Balloon>()
        .toList()
        .any((element) => element.isPlayer);
  }

  @override
  void onTap() {
    super.onTap();
    Bubble bubbleBullet = Bubble(
      center: player.center,
      angle: player.angle + pi / 2,
    );
    add(bubbleBullet);
  }
}
