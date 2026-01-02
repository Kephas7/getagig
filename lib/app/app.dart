import 'package:flutter/material.dart';
import 'package:getagig/app/theme/app_theme.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const LoginPage(),
    );
  }
}
