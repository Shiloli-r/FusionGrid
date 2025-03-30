import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../controllers/game_controller.dart';
import '../../models/move_direction.dart';

class GridTileWidget extends StatelessWidget {
  final int value;

  const GridTileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // Get the last move direction from the controller.
    final moveDirection = Get.find<GameController>().lastMoveDirection.value;
    Offset beginOffset;
    switch (moveDirection) {
      case MoveDirection.left:
        beginOffset = Offset(0.3, 0);
        break;
      case MoveDirection.right:
        beginOffset = Offset(-0.3, 0);
        break;
      case MoveDirection.up:
        beginOffset = Offset(0, 0.3);
        break;
      case MoveDirection.down:
        beginOffset = Offset(0, -0.3);
        break;
      default:
        beginOffset = Offset(0, 0);
    }

    return Container(
      decoration: BoxDecoration(
        color: getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: value > 0
            ? AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            // Combine slide and scale transitions.
            return SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            '$value',
            key: ValueKey<int>(value),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
            : SizedBox.shrink(),
      ),
    );
  }
}
