import 'dart:convert';
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
import 'package:web_socket_channel/web_socket_channel.dart';

const newPositionEvent = "NEW_POSITION";
const updateUsernameEvent = "UPDATE_USERNAME";

class BalloonWars extends FlameGame with HasDraggables, TapDetector {
  SpriteComponent background = SpriteComponent();
  late JoystickComponent joystick;
  late BalloonNextSpawn balloonNextSpawner;
  late double gameScreenHeight;
  late double gameScreenWidth;
  late Balloon player;
  late WebSocketChannel channel;
  final int cellAmount = 20;
  int balloonsCount = 1;
  final wsUrl = Uri.parse('ws://localhost:9090/ws');
  final Map<String, Balloon> balloons = {};
  String username = '';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initConnection();
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
      balloonSize: Balloon.balloonNormalSize,
    );
    // load background
    await _addBackground();
    await _addBoxes();
    _addJoystick();
    respawnPlayer();
  }

  @override
  void onTap() {
    super.onTap();
    player.shoot();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  _initConnection() {
    channel = WebSocketChannel.connect(wsUrl);
    channel.stream.listen(
      onError: (error) {
        print("#### ------ ERROR $error ------ ####");
      },
      (event) {
        print("#### ------ NEW EVENT $event ------ ####");
        var decodedData = jsonDecode(event);
        var eventName = decodedData['event'];
        var username = decodedData['username'];
        var data = decodedData['data'];
        switch (eventName) {
          case updateUsernameEvent:
            this.username = username;
            break;
          case newPositionEvent:
            var position = data['position'];
            var x = position['x'];
            var y = position['y'];
            var angle = data['angle'];

            if (player.username == username) {
              // update player position
              player.moveTo(Vector2(x, y), angle);
            } else {
              // update other player position
              var balloon = balloons[username];
              if (balloon == null) {
                // create new balloon
                balloon = Balloon(
                  balloonColor: getBalloonColor(),
                  position: Vector2(x, y),
                  isPlayer: false,
                  channel: channel,
                  username: "other",
                );
                balloons[username] = balloon;
                add(balloon);
              } else {
                // update balloon position
                balloon.moveTo(Vector2(x, y), angle);
              }
            }
            break;
          default:
            print("#### ------ UNKNOWN EVENT ------ ####");
        }
      },
    );
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

  void respawnPlayer({isInitialized = false}) {
    if (!isInitialized) {
      final Vector2 spawnPosition = balloonNextSpawner.getNextSpawnPosition();
      player = Balloon(
        balloonColor: BalloonColors.red,
        position: spawnPosition,
        isPlayer: true,
        channel: channel,
        username: username,
      );
      camera.followComponent(player, relativeOffset: const Anchor(0.5, 0.5));
      add(player);
    } else {
      player.respawn(newPosition: balloonNextSpawner.getNextSpawnPosition());
    }
  }

  BalloonColors getBalloonColor() {
    final random = Random();
    const colors = BalloonColors.values;
    return colors[random.nextInt(colors.length)];
  }
}
