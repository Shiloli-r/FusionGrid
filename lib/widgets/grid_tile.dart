import 'package:flutter/material.dart';

class GridTileBox extends StatelessWidget {
  final int value;

  const GridTileBox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey[300]!;
      case 2:
        return Color(0xFFB2DFDB); // Light teal
      case 4:
        return Color(0xFF80CBC4);
      case 8:
        return Color(0xFF4DB6AC);
      case 16:
        return Color(0xFF26A69A);
      case 32:
        return Color(0xFF009688);
      case 64:
        return Color(0xFF00897B);
      case 128:
        return Color(0xFF00796B);
      case 256:
        return Color(0xFF00695C);
      case 512:
        return Color(0xFF004D40);
      default:
        return Color(0xFF00332C);
    }
  }
}
