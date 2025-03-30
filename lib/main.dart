import 'package:flutter/material.dart';
import 'package:fusiongrid/views/home_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(FusionGridApp());
}

class FusionGridApp extends StatelessWidget {
  const FusionGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fusion Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: HomePage(),
    );
  }
}
