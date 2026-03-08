import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/widgets/app_logo.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Trigger auth check once splash loads
    Future.microtask(() {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Navigation is handled automatically by RouterNotifier and GoRouter
    // based on the authViewModelProvider state.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(height: 150, width: 150, forceLight: true),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
            const SizedBox(height: 10),
            Text(
              'Get-a-Gig',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
