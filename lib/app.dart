import 'package:flutter/material.dart';
import 'presentation/screens/character_search_screen.dart';

class PlannerApp extends StatelessWidget {
  const PlannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '던전앤파이터 플래너',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CharacterSearchScreen(),
    );
  }
}
