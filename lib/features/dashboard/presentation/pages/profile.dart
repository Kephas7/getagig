import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/routes/app_routes.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        AppRoutes.pushAndRemoveUntil(context, LoginPage());
      }
    });

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 USER HEADER
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 📧 EMAIL INFO
          _profileItem("Email", user.email),

          const SizedBox(height: 40),

          // 🚪 LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context, ref),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔔 LOGOUT CONFIRMATION DIALOG
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authViewModelProvider.notifier).logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
