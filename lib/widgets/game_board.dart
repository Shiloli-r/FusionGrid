import 'package:flutter/material.dart';
import 'grid_tile.dart';

class GameBoard extends StatelessWidget {
  final List<List<int>> board;

  const GameBoard({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    int gridSize = board.length;
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics:
            NeverScrollableScrollPhysics(), // Disable scrolling to capture vertical swipes
        itemCount: gridSize * gridSize,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ gridSize;
          int col = index % gridSize;
          int value = board[row][col];
          return GridTileWidget(value: value, row: row, col: col);
        },
      ),
    );
  }
}
