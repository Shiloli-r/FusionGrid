import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/grid_tile.dart';

class GamePage extends StatelessWidget {
  final GameController controller = Get.put(GameController());

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initializeGame();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fusion Grid"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < 0) {
            controller.swipeLeft();
          } else {
            controller.swipeRight();
          }
        },
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < 0) {
            controller.swipeUp();
          } else {
            controller.swipeDown();
          }
        },
        child: Obx(() => Column(
          children: [
            const SizedBox(height: 20),
            Text("Score: ${controller.score}", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: 16,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                  itemBuilder: (_, index) {
                    int x = index ~/ 4;
                    int y = index % 4;
                    return GridTileBox(value: controller.grid[x][y]);
                  },
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
