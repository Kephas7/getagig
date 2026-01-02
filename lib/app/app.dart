import 'package:flutter/material.dart';
import 'package:getagig/app/theme/app_theme.dart';
import 'package:getagig/features/splash/presentaion/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashPage(),
    );
  }
}
