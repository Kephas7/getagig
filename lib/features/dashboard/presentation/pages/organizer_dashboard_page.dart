import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/app/widgets/app_logo.dart';
import 'package:getagig/core/controllers/shake_refresh_controller.dart';
import 'package:getagig/features/dashboard/presentation/widgets/dashboard_app_drawer.dart';
import 'package:getagig/features/messaging/presentation/pages/messages_page.dart';
import 'package:getagig/features/musician/presentation/pages/profile.dart';
import 'package:getagig/features/gigs/presentation/pages/organizer_gigs_page.dart';
import 'package:getagig/features/gigs/presentation/pages/create_gig_page.dart';
import 'package:getagig/features/gigs/presentation/pages/edit_gig_page.dart';
import 'package:getagig/features/gigs/presentation/view_model/organizer_gigs_viewmodel.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';
import 'package:getagig/features/notifications/presentation/pages/notifications_page.dart';
import 'package:getagig/features/notifications/presentation/view_model/notifications_viewmodel.dart';

class OrganizerDashboardPage extends ConsumerStatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  ConsumerState<OrganizerDashboardPage> createState() =>
      _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState
    extends ConsumerState<OrganizerDashboardPage> {
  int _selectedIndex = 0;

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return _OrganizerHomeTab(
          onNavigateToTab: (index) {
            setState(() => _selectedIndex = index);
          },
        );
      case 1:
        return const OrganizerGigsPage();
      case 2:
        return const MessagesPage();
      case 3:
      default:
        return const Profile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unreadMessageCount = ref.watch(
      unreadMessageNotificationCountProvider,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DashboardAppDrawer(),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (drawerContext) => IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            onPressed: () => Scaffold.of(drawerContext).openDrawer(),
          ),
        ),
        title: const AppLogo(height: 48),
        actions: [
          const _NotificationIconButtonWithBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildScreen(),
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
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event_rounded),
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

class _OrganizerHomeTab extends ConsumerStatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const _OrganizerHomeTab({required this.onNavigateToTab});

  @override
  ConsumerState<_OrganizerHomeTab> createState() => _OrganizerHomeTabState();
}

class _OrganizerHomeTabState extends ConsumerState<_OrganizerHomeTab> {
  late DateTime _calendarMonth;
  late DateTime _selectedDate;
  late final ShakeRefreshController _shakeRefreshController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    Future.microtask(() {
      ref.read(organizerProfileViewModelProvider.notifier).getProfile();
    });

    _shakeRefreshController = ShakeRefreshController(
      onShake: _refreshFromShake,
    );
    _shakeRefreshController.start();
  }

  @override
  void dispose() {
    _shakeRefreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshHomeData() async {
    await Future.wait([
      ref.read(organizerGigsProvider.notifier).refresh(),
      ref.read(organizerProfileViewModelProvider.notifier).getProfile(),
    ]);
  }

  Future<void> _refreshFromShake() async {
    await _refreshHomeData();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Page refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    final gigsAsync = ref.watch(organizerGigsProvider);
    final profileState = ref.watch(organizerProfileViewModelProvider);
    final profile = profileState.profile;

    final gigs = gigsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <GigEntity>[],
    );
    final canPostGig = profile?.isVerified ?? false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final openGigs = gigs.where((g) => g.status.toLowerCase() == 'open').length;
    final closedGigs = gigs.where((g) {
      final status = g.status.toLowerCase();
      return status == 'closed' || status == 'filled';
    }).length;
    final upcomingGigs =
        gigs
            .where((g) => g.deadline != null && !g.deadline!.isBefore(today))
            .toList()
          ..sort((a, b) {
            final first = a.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
            final second = b.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
            return first.compareTo(second);
          });
    final thisMonthCount = gigs.where((g) {
      final deadline = g.deadline;
      if (deadline == null) return false;
      return deadline.year == now.year && deadline.month == now.month;
    }).length;

    final calendarEvents = gigs.where((gig) => gig.deadline != null).map((gig) {
      final date = gig.deadline!;
      return _OrganizerCalendarEvent(
        title: gig.title,
        location: gig.location,
        date: DateTime(date.year, date.month, date.day),
        status: gig.status.toLowerCase(),
        gig: gig,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    return RefreshIndicator(
      onRefresh: _refreshHomeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          _OrganizerHeroCard(
            openGigs: openGigs,
            thisMonthCount: thisMonthCount,
            upcomingCount: upcomingGigs.length,
            canPostGig: canPostGig,
            onPrimaryAction: () {
              if (canPostGig) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGigPage()),
                );
                return;
              }

              widget.onNavigateToTab(3);
            },
          ),
          const SizedBox(height: 16),
          _OrganizerStatsGrid(
            cards: [
              _OrganizerStatData(
                label: 'Total Gigs',
                value: '${gigs.length}',
                icon: Icons.work_outline_rounded,
                color: const Color(0xFF1A1B61),
              ),
              _OrganizerStatData(
                label: 'Open Gigs',
                value: '$openGigs',
                icon: Icons.event_available_rounded,
                color: const Color(0xFF10B981),
              ),
              _OrganizerStatData(
                label: 'Closed/Filled',
                value: '$closedGigs',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF6366F1),
              ),
              _OrganizerStatData(
                label: 'Upcoming',
                value: '${upcomingGigs.length}',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _OrganizerSectionHeader(title: 'Gig Calendar'),
          const SizedBox(height: 10),
          if (gigsAsync.isLoading)
            const _OrganizerLoadingPanel()
          else if (gigsAsync.hasError)
            _OrganizerErrorPanel(
              message: '${gigsAsync.error}',
              onRetry: () => ref.read(organizerGigsProvider.notifier).refresh(),
            )
          else if (calendarEvents.isEmpty)
            const _OrganizerEmptyPanel(
              title: 'No scheduled gigs yet',
              subtitle: 'Post a gig to start building your calendar.',
            )
          else
            _OrganizerCalendarPanel(
              month: _calendarMonth,
              selectedDate: _selectedDate,
              events: calendarEvents,
              onPreviousMonth: () {
                setState(() {
                  _calendarMonth = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month - 1,
                    1,
                  );
                });
              },
              onNextMonth: () {
                setState(() {
                  _calendarMonth = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month + 1,
                    1,
                  );
                });
              },
              onSelectDate: (date) {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
              onOpenGigEvent: (gig) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditGigPage(gig: gig)),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OrganizerHeroCard extends StatelessWidget {
  final int openGigs;
  final int thisMonthCount;
  final int upcomingCount;
  final bool canPostGig;
  final VoidCallback onPrimaryAction;

  const _OrganizerHeroCard({
    required this.openGigs,
    required this.thisMonthCount,
    required this.upcomingCount,
    required this.canPostGig,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = AppShellStyles.isDark(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dark ? const Color(0xFF171717) : const Color(0xFFFFFFFF),
            dark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F3F3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.secondary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Organizer Dashboard',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage gigs and applications in one place',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OrganizerInfoChip(text: '$openGigs Open Gigs'),
              _OrganizerInfoChip(text: '$thisMonthCount This Month'),
              _OrganizerInfoChip(text: '$upcomingCount Upcoming'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPrimaryAction,
            icon: Icon(
              canPostGig
                  ? Icons.add_circle_outline_rounded
                  : Icons.verified_outlined,
            ),
            label: Text(canPostGig ? 'Post a Gig' : 'Complete Verification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: canPostGig
                  ? colorScheme.secondary
                  : const Color(0xFFF59E0B),
              foregroundColor: dark ? const Color(0xFF111111) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerInfoChip extends StatelessWidget {
  final String text;

  const _OrganizerInfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppShellStyles.mutedSurface(context),
        border: Border.all(color: AppShellStyles.border(context)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.secondary,
        ),
      ),
    );
  }
}

class _OrganizerSectionHeader extends StatelessWidget {
  final String title;

  const _OrganizerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _OrganizerStatsGrid extends StatelessWidget {
  final List<_OrganizerStatData> cards;

  const _OrganizerStatsGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: AppShellStyles.glassCard(context, radius: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      card.label,
                      style: TextStyle(
                        color: AppShellStyles.mutedText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrganizerStatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OrganizerStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _OrganizerCalendarEvent {
  final String title;
  final String location;
  final DateTime date;
  final String status;
  final GigEntity gig;

  const _OrganizerCalendarEvent({
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.gig,
  });
}

class _OrganizerCalendarPanel extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final List<_OrganizerCalendarEvent> events;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<GigEntity> onOpenGigEvent;

  const _OrganizerCalendarPanel({
    required this.month,
    required this.selectedDate,
    required this.events,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    required this.onOpenGigEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthLabel = '${_monthNames[month.month - 1]} ${month.year}';
    final firstDayOffset = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final totalCells = ((firstDayOffset + daysInMonth + 6) ~/ 7) * 7;

    final selectedDayEvents =
        events.where((event) => _isSameDay(event.date, selectedDate)).toList()
          ..sort((a, b) => a.title.compareTo(b.title));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEvents =
        events.where((event) => !event.date.isBefore(today)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final thisMonthCount = events.where((event) {
      return event.date.year == month.year && event.date.month == month.month;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShellStyles.glassCard(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Color(0xFF9F7A3B),
              ),
              const SizedBox(width: 8),
              Text(
                'Gig Calendar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              _OrganizerCalendarNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
              ),
              const SizedBox(width: 6),
              _OrganizerCalendarNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            monthLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _OrganizerCalendarLegend(
                color: Color(0xFF1A1B61),
                label: 'Open Gig',
              ),
              _OrganizerCalendarLegend(
                color: Color(0xFF10B981),
                label: 'Filled/Closed',
              ),
              _OrganizerCalendarLegend(
                color: Color(0xFFF59E0B),
                label: 'Mixed Day',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OrganizerInfoChip(text: '$thisMonthCount This Month'),
              _OrganizerInfoChip(text: '${upcomingEvents.length} Upcoming'),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _OrganizerCalendarDayLabel(text: 'Sun'),
              _OrganizerCalendarDayLabel(text: 'Mon'),
              _OrganizerCalendarDayLabel(text: 'Tue'),
              _OrganizerCalendarDayLabel(text: 'Wed'),
              _OrganizerCalendarDayLabel(text: 'Thu'),
              _OrganizerCalendarDayLabel(text: 'Fri'),
              _OrganizerCalendarDayLabel(text: 'Sat'),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: totalCells,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                );
              }

              final date = DateTime(month.year, month.month, dayNumber);
              final isSelected = _isSameDay(date, selectedDate);
              final dayEvents = events
                  .where((event) => _isSameDay(event.date, date))
                  .toList();

              final hasOpen = dayEvents.any((event) => event.status == 'open');
              final hasClosed = dayEvents.any((event) {
                return event.status == 'filled' || event.status == 'closed';
              });

              Color borderColor = Colors.grey[300]!;
              Color fillColor = Colors.grey[50]!;
              Color textColor = const Color(0xFF1A1B61);

              if (hasOpen && hasClosed) {
                borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.35);
                fillColor = const Color(0xFFF59E0B).withValues(alpha: 0.12);
                textColor = const Color(0xFFB45309);
              } else if (hasClosed) {
                borderColor = const Color(0xFF10B981).withValues(alpha: 0.35);
                fillColor = const Color(0xFF10B981).withValues(alpha: 0.12);
                textColor = const Color(0xFF047857);
              } else if (hasOpen) {
                borderColor = const Color(0xFF1A1B61).withValues(alpha: 0.35);
                fillColor = const Color(0xFF1A1B61).withValues(alpha: 0.08);
                textColor = const Color(0xFF1A1B61);
              }

              if (isSelected) {
                borderColor = const Color(0xFF1A1B61);
                fillColor = const Color(0xFF1A1B61);
                textColor = Colors.white;
              }

              final dotColor = hasOpen && hasClosed
                  ? const Color(0xFFF59E0B)
                  : hasClosed
                  ? const Color(0xFF10B981)
                  : hasOpen
                  ? const Color(0xFF1A1B61)
                  : null;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectDate(date),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                      color: fillColor,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (dotColor != null)
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Events on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1B61),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedDayEvents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'No events scheduled for this date.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            )
          else
            Column(
              children: selectedDayEvents.map((event) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    dense: true,
                    onTap: () => onOpenGigEvent(event.gig),
                    title: Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1B61),
                      ),
                    ),
                    subtitle: Text(
                      event.location,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: _OrganizerStatusBadge(status: event.status),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text(
            'Upcoming Schedule',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1B61),
            ),
          ),
          const SizedBox(height: 8),
          if (upcomingEvents.isEmpty)
            Text(
              'No upcoming gigs yet.',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            )
          else
            Column(
              children: upcomingEvents.take(4).map((event) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    dense: true,
                    onTap: () => onOpenGigEvent(event.gig),
                    title: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1B61),
                      ),
                    ),
                    subtitle: Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: _OrganizerStatusBadge(status: event.status),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _OrganizerCalendarNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OrganizerCalendarNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppShellStyles.border(context)),
          color: AppShellStyles.mutedSurface(context),
        ),
        child: Icon(icon, size: 18, color: colorScheme.onSurface),
      ),
    );
  }
}

class _OrganizerCalendarLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _OrganizerCalendarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppShellStyles.mutedText(context),
          ),
        ),
      ],
    );
  }
}

class _OrganizerCalendarDayLabel extends StatelessWidget {
  final String text;

  const _OrganizerCalendarDayLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppShellStyles.mutedText(context),
        ),
      ),
    );
  }
}

class _OrganizerStatusBadge extends StatelessWidget {
  final String status;

  const _OrganizerStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isOpen = normalized == 'open';
    final isClosed = normalized == 'closed' || normalized == 'filled';
    final color = isOpen
        ? const Color(0xFF10B981)
        : isClosed
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _OrganizerLoadingPanel extends StatelessWidget {
  const _OrganizerLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      alignment: Alignment.center,
      decoration: AppShellStyles.glassCard(context, radius: 16),
      child: const CircularProgressIndicator(),
    );
  }
}

class _OrganizerErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrganizerErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShellStyles.glassCard(
        context,
        radius: 16,
        tint: Colors.redAccent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Something went wrong',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              color: AppShellStyles.mutedText(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _OrganizerEmptyPanel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _OrganizerEmptyPanel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppShellStyles.glassCard(context, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: AppShellStyles.mutedText(context)),
          ),
        ],
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
