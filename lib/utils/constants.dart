import 'package:flutter/material.dart';

Color getTileColor(int value) {
  switch (value) {
    case 2:
      return Colors.deepPurple.shade100;
    case 4:
      return Colors.deepPurple.shade300;
    case 8:
      return Color(0xFFFFAB91); // Coral
    case 16:
      return Color(0xFFFF8A65); // Vibrant Orange
    case 32:
      return Color(0xFF4DB6AC); // Teal
    case 64:
      return Color(0xFFE57373); // Soft Red
    case 128:
      return Color(0xFF1E88E5); // Blue 600
    case 256:
      return Color(0xFFAED581); // Soft Green
    case 512:
      return Color(0xFF8D6E63); // Dark Brown
    case 1024:
      return Color(0xFFD32F2F); // Dark Red
    case 2048:
      return Color(0xFF424242); // Dark Grey
    default:
      return Colors.grey[400]!;
  }
}
