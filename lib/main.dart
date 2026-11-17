import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const TraditionalBirdieApp());

class TraditionalBirdieApp extends StatelessWidget {
  const TraditionalBirdieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuttlecock Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8FAB)),
        scaffoldBackgroundColor: const Color(0xFFFFF8FB),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
