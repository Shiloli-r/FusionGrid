import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/move_direction.dart';

class GameController extends GetxController {
  final int gridSize = 4;
  // The board state: a 4x4 grid
  RxList<List<int>> board = RxList<List<int>>([]);
  // Score tracking
  RxInt score = 0.obs;
  RxInt highScore = 0.obs;
  // Track the last swipe direction for animations
  Rx<MoveDirection> lastMoveDirection = MoveDirection.none.obs;

  @override
  void onInit() {
    super.onInit();
    resetGame();
  }

  void resetGame() {
    score.value = 0;
    board.value = List.generate(
        gridSize, (_) => List.generate(gridSize, (_) => 0));
    addNewTile();
    addNewTile();
  }

  // Adds a new tile (2 or 4) at a random empty spot.
  void addNewTile() {
    List<List<int>> emptyPositions = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) {
          emptyPositions.add([i, j]);
        }
      }
    }
    if (emptyPositions.isNotEmpty) {
      final random = Random();
      var pos = emptyPositions[random.nextInt(emptyPositions.length)];
      board[pos[0]][pos[1]] = (random.nextDouble() < 0.9) ? 2 : 4;
      board.refresh();
    }
  }

  // Merges a single line (row or column) per 2048 rules.
  List<int> mergeLine(List<int> line) {
    // Remove zeros.
    List<int> newLine = line.where((x) => x != 0).toList();
    // Merge adjacent tiles.
    for (int i = 0; i < newLine.length - 1; i++) {
      if (newLine[i] == newLine[i + 1]) {
        newLine[i] *= 2;
        // Add merged value to score.
        score.value += newLine[i];
        newLine[i + 1] = 0;
        i++; // Skip the next element.
      }
    }
    // Remove zeros again and pad with zeros.
    newLine = newLine.where((x) => x != 0).toList();
    while (newLine.length < gridSize) {
      newLine.add(0);
    }
    return newLine;
  }

  // Move left.
  void moveLeft() {
    lastMoveDirection.value = MoveDirection.left;
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> original = List.from(board[i]);
      List<int> merged = mergeLine(board[i]);
      board[i] = merged;
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    if (moved) {
      if (score.value > highScore.value) highScore.value = score.value;
      addNewTile();
    }
    checkGameOver();
  }

  // Move right.
  void moveRight() {
    lastMoveDirection.value = MoveDirection.right;
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> original = List.from(board[i]);
      List<int> reversed = board[i].reversed.toList();
      List<int> merged = mergeLine(reversed).reversed.toList();
      board[i] = merged;
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    if (moved) {
      if (score.value > highScore.value) highScore.value = score.value;
      addNewTile();
    }
    checkGameOver();
  }

  // Move up.
  void moveUp() {
    lastMoveDirection.value = MoveDirection.up;
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = 0; i < gridSize; i++) {
        column.add(board[i][j]);
      }
      List<int> original = List.from(column);
      List<int> merged = mergeLine(column);
      for (int i = 0; i < gridSize; i++) {
        board[i][j] = merged[i];
      }
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    if (moved) {
      if (score.value > highScore.value) highScore.value = score.value;
      addNewTile();
    }
    checkGameOver();
  }

  // Move down.
  void moveDown() {
    lastMoveDirection.value = MoveDirection.down;
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> column = [];
      for (int i = 0; i < gridSize; i++) {
        column.add(board[i][j]);
      }
      List<int> original = List.from(column);
      List<int> reversed = column.reversed.toList();
      List<int> merged = mergeLine(reversed).reversed.toList();
      for (int i = 0; i < gridSize; i++) {
        board[i][j] = merged[i];
      }
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    if (moved) {
      if (score.value > highScore.value) highScore.value = score.value;
      addNewTile();
    }
    checkGameOver();
  }

  // Utility: compares two lists.
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Returns true if at least one move is possible.
  bool canMove() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) return true;
        // Check right neighbor.
        if (j < gridSize - 1 && board[i][j] == board[i][j + 1]) return true;
        // Check down neighbor.
        if (i < gridSize - 1 && board[i][j] == board[i + 1][j]) return true;
      }
    }
    return false;
  }

  // Checks for game over and shows a dialog if no moves are possible.
  void checkGameOver() {
    if (!canMove()) {
      // Show a game over dialog (non-dismissible).
      Get.dialog(
        AlertDialog(
          title: Text("Game Over"),
          content: Text("No more moves available!"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Get.back(); // Close the dialog.
              },
              child: Text("Restart"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}
