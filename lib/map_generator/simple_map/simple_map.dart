import 'package:test_app/map_generator/box_model.dart';

import '../map_generator.dart';

class SimpleMap extends MapGenerator {
  final double screenSize;
  final int cellAmount;
  final List<List<int>> map = [];

  SimpleMap({required this.screenSize, required this.cellAmount})
      : assert(cellAmount > 0) {
    _initMap();
  }

  @override
  List<BoxModel> generateMap() {
    double cellSize = screenSize / cellAmount;
    List<BoxModel> boxes = [];
    for (int r = 0; r < map.length; r++) {
      for (int c = 0; c < map[r].length; c++) {
        if (map[r][c] == 1) {
          BoxModel box = BoxModel(
            x: c * cellSize,
            y: r * cellSize,
            width: cellSize,
          );
          boxes.add(box);
        }
      }
    }
    return boxes;
  }

  _initMap() {
    for (int r = 0; r < cellAmount; r++) {
      map.add([]);
      for (int c = 0; c < cellAmount; c++) {
        if (r == 0 || r == cellAmount - 1 || c == 0 || c == cellAmount - 1) {
          map[r].add(1);
        } else {
          map[r].add(0);
        }
      }
    }
  }
}
