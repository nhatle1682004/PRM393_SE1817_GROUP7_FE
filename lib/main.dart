import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/home_screen.dart';

void main() {
  runApp(const EcoCollectApp());
}

class EcoCollectApp extends StatefulWidget {
  const EcoCollectApp({super.key});

  @override
  State<EcoCollectApp> createState() => _EcoCollectAppState();
}

class _EcoCollectAppState extends State<EcoCollectApp> {
  final LocaleController _locale = LocaleController();

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _locale,
      child: ListenableBuilder(
        listenable: _locale,
        builder: (context, _) {
          return MaterialApp(
            title: 'EcoCollect',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.green,
              fontFamily: 'Arial',
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
