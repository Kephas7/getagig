import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: const Icon(Icons.person, size: 40, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Musician Name",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("Singer • Guitarist"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          _profileItem("Email", "musician@gmail.com"),
          _profileItem("Location", "Kathmandu"),
          _profileItem("Experience", "3+ years"),
          _profileItem("Genres", "Rock, Acoustic"),

          const SizedBox(height: 30),

          // ⚙ Actions
          Column(
            children: [
              _actionButton("Edit Profile"),
              _actionButton("My Gigs"),
              _actionButton("Logout"),
            ],
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _actionButton(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: () {},
        child: Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
