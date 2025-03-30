import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/score_card.dart';

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
            // Score display area with animated score changes.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => ScoreCard(
                  label: "Score",
                  score: gameController.score.value,
                )),
                Obx(() => ScoreCard(
                  label: "High Score",
                  score: gameController.highScore.value,
                )),
              ],
            ),
            SizedBox(height: 16),
            // Game board container with gradient background, rounded corners, and shadow.
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
                    )
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
                  child: Obx(() => GameBoard(board: gameController.board.value)),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Additional restart button at the bottom.
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                gameController.resetGame();
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Placeholder for ads.
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('Ads Placeholder')),
            ),
          ],
        ),
      ),
    );
  }
}
