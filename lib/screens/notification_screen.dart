import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),

        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("No new notifications", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
