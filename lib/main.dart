import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'game_bord.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: Image.asset('assets/Group 1.png', width: 300),
        splashIconSize: 300,
        nextScreen: GameBoard(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.black,
      )
    );
  }
}
