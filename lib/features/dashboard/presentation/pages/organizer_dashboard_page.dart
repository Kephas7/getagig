import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/dashboard/presentation/pages/messages_page.dart';
import 'package:getagig/features/musician/presentation/pages/profile.dart';
import 'package:getagig/features/gigs/presentation/pages/organizer_gigs_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:getagig/features/dashboard/presentation/view_model/notifications_provider.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _OrganizerHomeTab(),
    OrganizerGigsPage(),
    MessagesPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF10B981), // Emerald
          unselectedItemColor: Colors.black26,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: "Hub",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event_rounded),
              label: "Events",
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

class _OrganizerHomeTab extends StatelessWidget {
  const _OrganizerHomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Organizer Hub",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1B61),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              _StatCard(
                label: "Active Gigs",
                value: "3",
                color: Color(0xFF10B981),
                icon: Icons.flash_on_rounded,
              ),
              SizedBox(width: 16),
              _StatCard(
                label: "Applicants",
                value: "24",
                color: Color(0xFF6366F1),
                icon: Icons.people_alt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const _SectionHeader(title: "Recent Activity"),
          const SizedBox(height: 16),
          const _ActivityCard(
            title: "New Application",
            subtitle: "John Doe applied for 'Jazz Night'",
            time: "2h ago",
            icon: Icons.person_add_rounded,
            color: Color(0xFF10B981),
          ),
          const _ActivityCard(
            title: "Gig Starting Soon",
            subtitle: "Acoustic Duo starts in 4 hours",
            time: "4h ago",
            icon: Icons.timer_rounded,
            color: Color(0xFFF59E0B),
          ),
          const _ActivityCard(
            title: "Interview Scheduled",
            subtitle: "Reviewing candidates for 'Summer Fest'",
            time: "Yesterday",
            icon: Icons.calendar_today_rounded,
            color: Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1B61),
        letterSpacing: -0.5,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1B61),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: Colors.black26,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
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
    final unreadCount = ref.watch(notificationsProvider).maybeWhen(
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
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
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

