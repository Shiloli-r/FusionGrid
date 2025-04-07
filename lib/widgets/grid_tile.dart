import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../controllers/game_controller.dart';
import '../../models/move_direction.dart';

class GridTileWidget extends StatelessWidget {
  final int value;
  final int row;
  final int col;

  const GridTileWidget({
    super.key,
    required this.value,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final isNewTile = gameController.lastNewTile.value == Point(row, col);

    final moveDirection = gameController.lastMoveDirection.value;
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
        boxShadow:
            isNewTile
                ? [
                  BoxShadow(
                    color: Colors.purpleAccent.shade100,
                    blurRadius: 5,
                  ),
                ]
                : [],
      ),
      child: Center(
        child:
            value > 0
                ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow pulse behind new tile
                    if (isNewTile)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: 1.0 - value,
                            child: Container(
                              width: 64 + (value * 20),
                              height: 64 + (value * 20),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),

                    // Main animated tile
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: isNewTile ? 0.3 : 1.0,
                        end: 1.0,
                      ),
                      duration:
                          isNewTile
                              ? const Duration(milliseconds: 500)
                              : const Duration(milliseconds: 0),
                      curve: isNewTile ? Curves.elasticOut : Curves.linear,
                      builder: (context, anim, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..scale(anim)
                                ..rotateZ(isNewTile ? (1.0 - anim) * 0.5 : 0),
                          child: child,
                        );
                      },
                      child: Text(
                        '$value',
                        key: ValueKey('${row}_$col\_$value'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
