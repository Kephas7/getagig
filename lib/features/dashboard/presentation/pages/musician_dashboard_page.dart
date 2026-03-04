import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/presentation/pages/gigs_explore_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/musician_home_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/messages_page.dart';
import 'package:getagig/features/musician/presentation/pages/profile.dart';
import 'package:getagig/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:getagig/features/dashboard/presentation/view_model/notifications_viewmodel.dart';

class MusicianDashboardPage extends StatefulWidget {
  const MusicianDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _MusicianDashboardPageState();
}

class _MusicianDashboardPageState extends State<MusicianDashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    MusicianHomePage(),
    GigsExplorePage(),
    MessagesPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Image.asset("assets/images/mylogo.png", height: 40),
        ),
        actions: [
          const _NotificationIconButtonWithBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black26,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: "Gigs",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}

class _NotificationIconButtonWithBadge extends ConsumerWidget {
  const _NotificationIconButtonWithBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref
        .watch(notificationsProvider)
        .maybeWhen(
          data: (notifications) => notifications.where((n) => !n.isRead).length,
          orElse: () => 0,
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
