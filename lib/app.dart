import 'package:flutter/material.dart';
import 'package:getagig/screens/home_screen.dart';
import 'package:getagig/screens/login_screen.dart';
import 'package:getagig/screens/onboard_screen.dart';
import 'package:getagig/screens/signup_screen.dart';
import 'package:getagig/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboard': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
      home: OnboardingScreen(),
    );
  }
}
