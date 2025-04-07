import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/move_direction.dart';
import '../widgets/game_over_dialog.dart';
import '../services/ad_service.dart';

class GameController extends GetxController {
  final int gridSize = 4;
  // Board state and score.
  RxList<List<int>> board = RxList<List<int>>([]);
  RxInt score = 0.obs;
  RxInt highScore = 0.obs;
  Rx<Point<int>?> lastNewTile = Rx<Point<int>?>(null);
  Rx<MoveDirection> lastMoveDirection = MoveDirection.none.obs;

  // Powerups: one free Undo and one free Shuffle per round.
  RxInt undoMovesLeft = 1.obs;
  RxInt shuffleMovesLeft = 1.obs;

  // Flags to track if an extra powerup (via ad) has been used.
  RxBool adExtraUndoUsed = false.obs;
  RxBool adExtraShuffleUsed = false.obs;

  // To support undo, store the previous board state and score.
  List<List<int>>? previousBoard;
  int? previousScore;

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
    resetGame();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore.value = prefs.getInt('highScore') ?? 0;
    final loadedHighScore = prefs.getInt('highScore') ?? 0;
    print("Loaded highScore: $loadedHighScore");
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore.value);
    print("Saved highScore: ${highScore.value}");
  }

  // Whenever you update highScore, call _saveHighScore.
  void updateHighScoreIfNeeded() {
    if (score.value > highScore.value) {
      highScore.value = score.value;
      _saveHighScore();
    }
  }

  void resetGame() {
    score.value = 0;
    // Reset powerup counters.
    undoMovesLeft.value = 1;
    shuffleMovesLeft.value = 1;
    adExtraUndoUsed.value = false;
    adExtraShuffleUsed.value = false;
    board.value = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => 0),
    );
    previousBoard = null;
    previousScore = null;
    addNewTile();
    addNewTile();
  }

  // Save state for undo.
  void storePreviousState() {
    previousBoard = board.value.map((row) => [...row]).toList();
    previousScore = score.value;
  }

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
      lastNewTile.value = Point(pos[0], pos[1]); // Track the last added tile
      board.refresh();
    }
  }

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

  // In each move method, store state, then process the move.
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
      addNewTile();
      updateHighScoreIfNeeded();
    }
    checkGameOver();
  }

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
      addNewTile();
      updateHighScoreIfNeeded();
    }
    checkGameOver();
  }

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
      addNewTile();
      updateHighScoreIfNeeded();
    }
    checkGameOver();
  }

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
      addNewTile();
      updateHighScoreIfNeeded();
    }
    checkGameOver();
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

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

  void checkGameOver() {
    if (!canMove()) {
      Get.dialog(
        GameOverDialog(finalScore: score.value),
        barrierDismissible: false,
      );
    }
  }

  // Powerup methods.
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

  // Watch a rewarded ad for extra powerup.
  void watchAdForExtraPowerup(String type) {
    // If already used for this type, do nothing.
    if (type == "undo" && adExtraUndoUsed.value) return;
    if (type == "shuffle" && adExtraShuffleUsed.value) return;

    AdService.instance.loadRewardedAd(
      onAdLoaded: () {
        AdService.instance.showRewardedAd(
          onUserEarnedReward: (ad, RewardItem reward) {
            if (type == "undo") {
              undoMovesLeft.value++;
              adExtraUndoUsed.value = true;
            } else if (type == "shuffle") {
              shuffleMovesLeft.value++;
              adExtraShuffleUsed.value = true;
            }
          },
          onAdClosed: () {},
        );
      },
      onAdFailedToLoad: () {
        Get.snackbar(
          "No Ads at the moment",
          "Failed to load ad, please try again later.",
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
