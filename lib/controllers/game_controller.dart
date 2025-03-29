import 'dart:math';

import 'package:get/get.dart';

class GameController extends GetxController {
  var grid = List.generate(4, (_) => List.generate(4, (_) => 0)).obs;
  var score = 0.obs;

  void initializeGame() {
    grid.value = List.generate(4, (_) => List.generate(4, (_) => 0));
    score.value = 0;
    _addRandomTile();
    _addRandomTile();
  }

  void swipeLeft() {
    // Basic merging logic here (you'll enhance this later)
    for (var row in grid) {
      var newRow = row.where((e) => e != 0).toList();
      for (int i = 0; i < newRow.length - 1; i++) {
        if (newRow[i] == newRow[i + 1]) {
          newRow[i] *= 2;
          score.value += newRow[i];
          newRow[i + 1] = 0;
        }
      }
      newRow = newRow.where((e) => e != 0).toList();
      while (newRow.length < 4) {
        newRow.add(0);
      }
      row.setAll(0, newRow);
    }
    _addRandomTile();
  }

  void _addRandomTile() {
    final emptyTiles = <Map<String, int>>[];
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 4; j++) {
        if (grid[i][j] == 0) emptyTiles.add({"x": i, "y": j});
      }
    }
    if (emptyTiles.isNotEmpty) {

      final random = Random();
      final spot = emptyTiles[random.nextInt(emptyTiles.length)];
      grid[spot["x"]!][spot["y"]!] = random.nextInt(2) == 0 ? 2 : 4;
    }
  }

  void swipeRight() {
    for (var row in grid) {
      var reversed = row.reversed.toList();
      var merged = _merge(reversed);
      row.setAll(0, merged.reversed.toList());
    }
    _addRandomTile();
  }

  void swipeUp() {
    for (var col = 0; col < 4; col++) {
      var column = List.generate(4, (row) => grid[row][col]);
      var merged = _merge(column);
      for (var row = 0; row < 4; row++) {
        grid[row][col] = merged[row];
      }
    }
    _addRandomTile();
  }

  void swipeDown() {
    for (var col = 0; col < 4; col++) {
      var column = List.generate(4, (row) => grid[row][col]);
      var reversed = column.reversed.toList();
      var merged = _merge(reversed);
      var finalColumn = merged.reversed.toList();
      for (var row = 0; row < 4; row++) {
        grid[row][col] = finalColumn[row];
      }
    }
    _addRandomTile();
  }

  List<int> _merge(List<int> tiles) {
    var filtered = tiles.where((e) => e != 0).toList();
    for (int i = 0; i < filtered.length - 1; i++) {
      if (filtered[i] == filtered[i + 1]) {
        filtered[i] *= 2;
        score.value += filtered[i];
        filtered[i + 1] = 0;
      }
    }
    filtered = filtered.where((e) => e != 0).toList();
    while (filtered.length < 4) {
      filtered.add(0);
    }
    return filtered;
  }

}
