import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/score_card.dart';
import '../widgets/banner_ad_widget.dart';

class GamePage extends StatelessWidget {
  final GameController gameController = Get.put(GameController());

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fusion Grid', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              gameController.resetGame();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score display area.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => ScoreCard(
                    label: "Score",
                    score: gameController.score.value,
                  ),
                ),
                Obx(
                  () => ScoreCard(
                    label: "High Score",
                    score: gameController.highScore.value,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Game board container.
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy < -100) {
                      HapticFeedback.lightImpact();
                      gameController.moveUp();
                    } else if (details.velocity.pixelsPerSecond.dy > 100) {
                      HapticFeedback.lightImpact();
                      gameController.moveDown();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < -100) {
                      HapticFeedback.lightImpact();
                      gameController.moveLeft();
                    } else if (details.velocity.pixelsPerSecond.dx > 100) {
                      HapticFeedback.lightImpact();
                      gameController.moveRight();
                    }
                  },
                  child: Obx(
                    () => GameBoard(board: gameController.board.value),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Powerups row: Undo, Restart, and Shuffle.
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (gameController.undoMovesLeft.value > 0) {
                          HapticFeedback.mediumImpact();
                          gameController.undoMove();
                        } else {
                          _showWatchAdDialog(context, "undo", gameController);
                        }
                      },
                      icon: Icon(Icons.undo, size: 16, color: Colors.white),
                      label: Text(
                        'Undo (${gameController.undoMovesLeft.value})',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        gameController.resetGame();
                      },
                      icon: Icon(Icons.refresh, size: 16, color: Colors.white),
                      label: Text(
                        'Restart',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (gameController.undoMovesLeft.value > 0) {
                          HapticFeedback.mediumImpact();
                          gameController.undoMove();
                        } else {
                          _showWatchAdDialog(context, "shuffle", gameController);
                        }
                      },
                      icon: Icon(Icons.shuffle, size: 16, color: Colors.white),
                      label: Text(
                        'Shuffle (${gameController.shuffleMovesLeft.value})',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Banner Ad at the bottom.
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  void _showWatchAdDialog(BuildContext context, String type, GameController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Extra ${type.capitalize!}"),
          content: Text("You have used all your free $type powerups. Would you like to watch a short ad to get an extra $type?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.watchAdForExtraPowerup(type);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

}
