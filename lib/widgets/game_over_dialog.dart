import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameOverDialog extends StatelessWidget {
  final int finalScore;

  const GameOverDialog({super.key, required this.finalScore});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Dialog(
      backgroundColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $finalScore',
              style: const TextStyle(fontSize: 24, color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Obx(
              () => Column(
                children: [
                  if (gameController.undoMovesLeft.value > 0)
                    _buildActionButton(
                      label: 'Undo Move',
                      onPressed: () {
                        Get.back(); // Close dialog
                        gameController.undoMove();
                      },
                    )
                  else
                    _buildActionButton(
                      label: 'Watch Ad to Undo',
                      onPressed: () {
                        Get.back();
                        gameController.watchAdForExtraPowerup('undo');
                      },
                    ),
                  const SizedBox(height: 12),
                  if (gameController.shuffleMovesLeft.value > 0)
                    _buildActionButton(
                      label: 'Shuffle Board',
                      onPressed: () {
                        Get.back();
                        gameController.shuffleBoard();
                      },
                    )
                  else
                    _buildActionButton(
                      label: 'Watch Ad to Shuffle',
                      onPressed: () {
                        Get.back();
                        gameController.watchAdForExtraPowerup('shuffle');
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                gameController.resetGame();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Restart Game',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
