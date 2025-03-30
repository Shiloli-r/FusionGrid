import 'dart:math';
import 'package:get/get.dart';
import '../models/move_direction.dart';
import '../widgets/game_over_dialog.dart';

class GameController extends GetxController {
  final int gridSize = 4;
  // Board state and score.
  RxList<List<int>> board = RxList<List<int>>([]);
  RxInt score = 0.obs;
  RxInt highScore = 0.obs;
  Rx<MoveDirection> lastMoveDirection = MoveDirection.none.obs;

  // Powerups: one Undo and one Shuffle per round.
  RxInt undoMovesLeft = 1.obs;
  RxInt shuffleMovesLeft = 1.obs;

  // To support undo, store the previous board state and score.
  List<List<int>>? previousBoard;
  int? previousScore;

  @override
  void onInit() {
    super.onInit();
    resetGame();
  }

  void resetGame() {
    score.value = 0;
    // Reset powerup counters.
    undoMovesLeft.value = 1;
    shuffleMovesLeft.value = 1;
    board.value = List.generate(
        gridSize, (_) => List.generate(gridSize, (_) => 0));
    previousBoard = null;
    previousScore = null;
    addNewTile();
    addNewTile();
  }

  // Call this to store the current state before a move.
  void storePreviousState() {
    previousBoard = board.value.map((row) => [...row]).toList();
    previousScore = score.value;
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

  // Merges a line (row or column) following 2048 rules.
  List<int> mergeLine(List<int> line) {
    List<int> newLine = line.where((x) => x != 0).toList();
    for (int i = 0; i < newLine.length - 1; i++) {
      if (newLine[i] == newLine[i + 1]) {
        newLine[i] *= 2;
        score.value += newLine[i];
        newLine[i + 1] = 0;
        i++;
      }
    }
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
    storePreviousState();
    for (int i = 0; i < gridSize; i++) {
      List<int> original = List.from(board[i]);
      List<int> merged = mergeLine(board[i]);
      board[i] = merged;
      if (!_listEquals(original, merged)) moved = true;
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
    storePreviousState();
    for (int i = 0; i < gridSize; i++) {
      List<int> original = List.from(board[i]);
      List<int> reversed = board[i].reversed.toList();
      List<int> merged = mergeLine(reversed).reversed.toList();
      board[i] = merged;
      if (!_listEquals(original, merged)) moved = true;
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
    storePreviousState();
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
      if (!_listEquals(original, merged)) moved = true;
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
    storePreviousState();
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
      if (!_listEquals(original, merged)) moved = true;
    }
    if (moved) {
      if (score.value > highScore.value) highScore.value = score.value;
      addNewTile();
    }
    checkGameOver();
  }

  // Undo Move powerup.
  void undoMove() {
    if (undoMovesLeft.value > 0 &&
        previousBoard != null &&
        previousScore != null) {
      board.value = previousBoard!;
      score.value = previousScore!;
      board.refresh();
      undoMovesLeft.value--;
    }
  }

  // Shuffle Board powerup.
  void shuffleBoard() {
    if (shuffleMovesLeft.value > 0) {
      List<int> flat = board.value.expand((row) => row).toList();
      flat.shuffle();
      List<List<int>> newBoard = [];
      for (int i = 0; i < gridSize; i++) {
        newBoard.add(flat.sublist(i * gridSize, (i + 1) * gridSize));
      }
      board.value = newBoard;
      board.refresh();
      shuffleMovesLeft.value--;
    }
  }

  // Utility: Compare two lists.
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
        if (j < gridSize - 1 && board[i][j] == board[i][j + 1]) return true;
        if (i < gridSize - 1 && board[i][j] == board[i + 1][j]) return true;
      }
    }
    return false;
  }

  // Check for game over.
  void checkGameOver() {
    if (!canMove()) {
      Get.dialog(
        // Use our custom game over dialog.
        GameOverDialog(finalScore: score.value),
        barrierDismissible: false,
      );
    }
  }
}
