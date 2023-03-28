import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:test_app/flame_layer/flame_layer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setLandscape();
  Flame.device.fullScreen();
  runApp(const MaterialApp(
    home: Scaffold(
      body: FlameLayer(),
    ),
  ));
}
