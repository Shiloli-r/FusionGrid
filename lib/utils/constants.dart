import 'package:flutter/material.dart';

Color getTileColor(int value) {
  switch (value) {
    case 2:
      return Colors.deepPurple.shade100;
    case 4:
      return Colors.deepPurple.shade200;
    case 8:
      return Colors.deepPurple.shade300;
    case 16:
      return Colors.deepPurple.shade400;
    case 32:
      return Colors.deepPurple.shade500;
    case 64:
      return Colors.deepPurple.shade600;
    case 128:
      return Colors.deepPurple.shade700;
    case 256:
      return Colors.deepPurple.shade800;
    case 512:
      return Colors.deepPurple.shade900;
    case 1024:
      return Colors.teal.shade700;
    case 2048:
      return Colors.teal.shade800;
    default:
      return Colors.grey[400]!;
  }
}
