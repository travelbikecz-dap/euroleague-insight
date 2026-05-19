import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EuroLeagueApp());
}

class EuroLeagueApp extends StatelessWidget {
  const EuroLeagueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EuroLeague Predictor',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}