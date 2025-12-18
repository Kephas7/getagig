import 'package:flutter/material.dart';
import 'package:getagig/screens/musician_navbar_screens/gigs.dart';
import 'package:getagig/screens/musician_navbar_screens/home.dart';
import 'package:getagig/screens/musician_navbar_screens/messages.dart';
import 'package:getagig/screens/musician_navbar_screens/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> lstBottomSCcreen = [
    const Home(),
    const Gigs(),
    const Messages(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        title: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
          child: Image.asset("assets/images/mylogo.png", height: 50),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ],
      ),

      body: lstBottomSCcreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },

        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: "Gigs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
