import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:test_app/character/player.dart';
import 'package:test_app/map_generator/box_model.dart';
import 'package:test_app/map_generator/map_generator.dart';
import 'package:test_app/map_generator/simple_map/simple_map.dart';
import 'package:test_app/sprites/balloon/balloon.dart';
import 'package:test_app/sprites/box_component/box_component.dart';
import 'package:test_app/sprites/bullet/bullet.dart';
import 'package:test_app/sprites/enemy_component/enemy_component.dart';

class MyGame extends FlameGame
    with HasCollisionDetection, HasDraggables, TapDetector {
  SpriteComponent background = SpriteComponent();
  late JoystickComponent joystick;
  final int cellAmount = 20;
  late double gameScreenHeight;
  late double gameScreenWidth;
  // int enemyCount = 1;
  List<Vector2> enemyPositions = [];
  int lastSpawnPosition = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameScreenHeight = size[0];
    gameScreenWidth = size[1];
    double cellSize = gameScreenHeight / cellAmount;
    // set camera
    camera.viewport =
        FixedResolutionViewport(Vector2(gameScreenHeight, gameScreenWidth));
    // set spawn positions
    enemyPositions = [
      Vector2(100, 100),
      Vector2(gameScreenHeight - 100, 100),
      Vector2(100, gameScreenHeight - 100),
      Vector2(gameScreenHeight - 100, gameScreenHeight - 100),
    ];
    // load background
    background
      ..sprite = await loadSprite('background.png')
      ..size = Vector2(gameScreenHeight, gameScreenHeight);
    background.setColor(Colors.grey);
    add(background);

    // load bloxes
    await addBoxes();
    // create joystick
    addJoystick();
    // addPlayer();
    // _spawnEnemies();
  }

  void addJoystick() {
    final knobPaint = BasicPalette.white.paint();
    final backgroundPaint = BasicPalette.lightGray.paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);
  }

  Future<void> addBoxes() async {
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

  // @override
  // void onTapDown(TapDownInfo info) async {
  //   super.onTapDown(info);
  //   Bullet bullet = Bullet(
  //     sprite: await loadSprite('player.png'),
  //     center: player.center,
  //     angle: player.angle + Player.splitAngle,
  //   );
  //   add(bullet);
  // }

  @override
  void update(double dt) {
    super.update(dt);
    _checkBoxBulletCollision();
    _checkBulletEnemyCollision();
    // _spawnEnemies();
  }

  void _checkBoxBulletCollision() {
    List<Bullet> bullets = children.whereType<Bullet>().toList();
    List<BoxComponent> boxes = children.whereType<BoxComponent>().toList();
    for (Bullet bullet in bullets) {
      for (BoxComponent box in boxes) {
        if (bullet.toRect().overlaps(box.toRect())) {
          bullet.removeFromParent();
        }
      }
    }
  }

  void _checkBulletEnemyCollision() {
    List<Bullet> bullets = children.whereType<Bullet>().toList();
    List<EnemyComponent> enemies =
        children.whereType<EnemyComponent>().toList();
    for (Bullet bullet in bullets) {
      for (EnemyComponent enemy in enemies) {
        if (bullet.toRect().overlaps(enemy.toRect())) {
          bullet.removeFromParent();
          enemy.removeFromParent();
        }
      }
    }
  }

  // void _spawnEnemies() {
  //   List<EnemyComponent> enemies =
  //       children.whereType<EnemyComponent>().toList();
  //   if (enemies.length < enemyCount) {
  //     EnemyComponent enemy = EnemyComponent(
  //       position: enemyPositions[lastSpawnPosition],
  //     )..add(ColorEffect(
  //         Colors.red,
  //         const Offset(0.0, 0.6),
  //         EffectController(duration: 0.0),
  //       ));
  //     lastSpawnPosition++;
  //     if (lastSpawnPosition >= enemyPositions.length) {
  //       lastSpawnPosition = 0;
  //     }
  //     add(enemy);
  //   }
  // }
}
