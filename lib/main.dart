import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
