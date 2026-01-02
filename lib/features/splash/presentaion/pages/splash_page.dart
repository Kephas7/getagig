import 'package:flutter/material.dart';
import 'package:getagig/app/routes/app_routes.dart';
import 'package:getagig/features/onboard/presentation/pages/onboard_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      AppRoutes.pushReplacement(context, OnboardPage());
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/mylogo.png", height: 150, width: 150),
          ],
        ),
      ),
    );
  }
}
