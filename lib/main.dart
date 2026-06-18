import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/screens/home/home_screen.dart';

import 'screens/login/login_screen.dart';

void main() {
  runApp(const EcoCollectApp());
}

class EcoCollectApp extends StatelessWidget {
  const EcoCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoCollect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}
