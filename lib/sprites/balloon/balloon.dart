import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test_app/flame_layer/balloon_wars.dart';
import 'package:test_app/sprites/bubble/bubble.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum BalloonColors { blue, green, pink, purple, red, yellow }

class Balloon extends SpriteComponent with HasGameRef<BalloonWars> {
  static const double splitAngle = 0;
  static const double balloonNormalSize = 50;
  static const double balloonMinSize = 30;
  static const double balloonMaxSize = 55;
  static const double balloonSpeed = 5;
  static const double balloonsMinDistance = 200;
  static const String enemyId = 'enemy';
  static const String playerId = 'player';
  final BalloonColors balloonColor;
  final WebSocketChannel channel;
  final bool isPlayer;
  final String username;
  double dtCumulative = 0;

  Balloon(
      {required this.balloonColor,
      this.isPlayer = false,
      required Vector2 position,
      required this.channel,
      required this.username}) {
    debugMode = true;
    this.position = position;
    // generate random id
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    final spriteSize = Vector2(balloonNormalSize, balloonNormalSize);
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
      _checkJoystickMovement(dt);
    }
  }

  void respawn({required Vector2 newPosition}) {
    position = newPosition;
    size = Vector2(balloonNormalSize, balloonNormalSize);
  }

  void addAir(double amount) {
    if (size.x < balloonMaxSize) {
      size += Vector2(amount, amount);
    } else if (isPlayer) {
      gameRef.respawnPlayer(isInitialized: true);
    } else {
      gameRef.remove(this);
    }
  }

  void removeAir(double amount) {
    if (size.x > balloonMinSize) {
      size -= Vector2(amount, amount);
    } else {
      gameRef.remove(this);
    }
  }

  void shoot() {
    if (size.x <= Balloon.balloonMinSize) return;
    Bubble bubbleBullet = Bubble(
      center: center,
      angle: angle + pi / 2,
      shooterSize: getMaxWidth(),
      shooterId: username,
    );
    removeAir(Bubble.airAmount);
    gameRef.add(bubbleBullet);
  }

  void _findAndAttackPlayer(double dt) {
    Balloon player = gameRef.player;
    // check if player component exists
    bool isStillContains = gameRef.children.contains(player);
    if (!isStillContains) return;
    // find player
    var angleDeg =
        atan2(player.center.y - center.y, player.center.x - center.x);
    angle = angleDeg - pi / 2 + splitAngle;
    // move towards player if distance is greater than
    if (player.center.distanceTo(center) > balloonsMinDistance) {
      Vector2 directionVector = Vector2(20, 0);
      directionVector.rotate(angle + pi / 2);
      position.add(directionVector * dt * balloonSpeed);
    } else {
      // shoot every 1 second
      dtCumulative += dt;
      if (dtCumulative > 2) {
        shoot();
        dtCumulative = 0;
      }
    }
  }

  void _checkJoystickMovement(double dt) {
    if (!isPlayer) return;
    var newPosition = position + gameRef.joystick.delta * dt * balloonSpeed;
    var newAngle = angle;
    if (gameRef.joystick.delta != Vector2.zero()) {
      var angleDeg = atan2(gameRef.joystick.delta.y, gameRef.joystick.delta.x);
      newAngle = angleDeg - pi / 2 + splitAngle;
    }
    if (newPosition == position && newAngle == angle) return;
    var data = {
      "event": newPositionEvent,
      "username": username,
      "data": {
        "position": {
          "x": newPosition.x,
          "y": newPosition.y,
        },
        "angle": newAngle,
      }
    };
    EasyDebounce.debounce(
      'move',
      const Duration(milliseconds: 10),
      () => {
        channel.sink.add(jsonEncode(data)),
      },
    );
  }

  void moveTo(Vector2 newPosition, double newAngle) {
    position = newPosition;
    angle = newAngle;
  }

  double getMaxWidth() {
    double currentSize = size.x;
    return sqrt(2) * (currentSize / 2);
  }
}
