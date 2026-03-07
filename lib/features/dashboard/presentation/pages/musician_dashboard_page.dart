import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/app/widgets/app_logo.dart';
import 'package:getagig/features/gigs/presentation/pages/gigs_explore_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/musician_home_page.dart';
import 'package:getagig/features/messaging/presentation/pages/messages_page.dart';
import 'package:getagig/features/musician/presentation/pages/profile.dart';
import 'package:getagig/features/notifications/presentation/pages/notifications_page.dart';
import 'package:getagig/features/notifications/presentation/view_model/notifications_viewmodel.dart';

class MusicianDashboardPage extends ConsumerStatefulWidget {
  const MusicianDashboardPage({super.key});

  @override
  ConsumerState<MusicianDashboardPage> createState() =>
      _MusicianDashboardPageState();
}

class _MusicianDashboardPageState extends ConsumerState<MusicianDashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    MusicianHomePage(),
    GigsExplorePage(),
    MessagesPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unreadMessageCount = ref.watch(
      unreadMessageNotificationCountProvider,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: const AppLogo(height: 48),
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
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: AppShellStyles.glassCard(context, radius: 22),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: colorScheme.onSurface,
              unselectedItemColor: AppShellStyles.mutedText(context),
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore_rounded),
                  label: "Gigs",
                ),
                BottomNavigationBarItem(
                  icon: _MessageTabIconWithBadge(
                    icon: Icons.chat_bubble_outline_rounded,
                    unreadCount: unreadMessageCount,
                  ),
                  activeIcon: _MessageTabIconWithBadge(
                    icon: Icons.chat_bubble_rounded,
                    unreadCount: unreadMessageCount,
                  ),
                  label: "Messages",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTabIconWithBadge extends StatelessWidget {
  final IconData icon;
  final int unreadCount;

  const _MessageTabIconWithBadge({
    required this.icon,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (unreadCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: AppShellStyles.glassCard(context, radius: 14),
        child: Icon(icon, color: colorScheme.onSurface, size: 24),
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
