import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/controllers/shake_refresh_controller.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/gigs/presentation/view_model/gigs_feed_viewmodel.dart';
import 'package:getagig/features/gigs/presentation/pages/gig_details_page.dart';
import 'package:getagig/features/gigs/presentation/pages/gigs_explore_page.dart';
import 'package:getagig/features/applications/presentation/view_model/my_applications_viewmodel.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';

class MusicianHomePage extends ConsumerStatefulWidget {
  const MusicianHomePage({super.key});

  @override
  ConsumerState<MusicianHomePage> createState() => _MusicianHomePageState();
}

class _MusicianHomePageState extends ConsumerState<MusicianHomePage> {
  late DateTime _calendarMonth;
  late DateTime _selectedDate;
  late final ShakeRefreshController _shakeRefreshController;
  List<_MusicianPlannedEvent> _plannedEvents = [];
  bool _isLoadingPlannedEvents = false;
  bool _isSyncingCalendarEvent = false;
  bool _isAddEventDialogOpen = false;
  String? _lastCalendarErrorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    Future.microtask(() => _loadPlannedEvents(showError: false));

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

  Future<void> _refreshDashboard() async {
    await Future.wait([
      ref.read(gigsFeedProvider.notifier).refresh(),
      ref.read(myApplicationsProvider.notifier).refresh(),
      _loadPlannedEvents(showError: false),
    ]);
  }

  Future<void> _refreshFromShake() async {
    await _refreshDashboard();
    _showPageSnackBar('Page refreshed');
  }

  Future<void> _loadPlannedEvents({bool showError = true}) async {
    if (mounted) {
      setState(() => _isLoadingPlannedEvents = true);
    }

    try {
      final response = await ref
          .read(apiClientProvider)
          .get(ApiEndpoints.musicianCalendarEvents);

      final responseData = response.data;
      if (responseData is! Map || responseData['success'] != true) {
        throw Exception(
          responseData is Map
              ? (responseData['message'] ?? 'Failed to load calendar events')
              : 'Failed to load calendar events',
        );
      }

      final data = responseData['data'];
      final loadedEvents = <_MusicianPlannedEvent>[];

      if (data is List) {
        for (final raw in data) {
          final parsed = _parsePlannedEvent(raw);
          if (parsed != null) {
            loadedEvents.add(parsed);
          }
        }
      }

      loadedEvents.sort((a, b) => a.date.compareTo(b.date));

      if (mounted) {
        setState(() {
          _plannedEvents = loadedEvents;
        });
      }
    } catch (_) {
      if (mounted && showError) {
        _showPageSnackBar('Failed to load calendar events.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlannedEvents = false);
      }
    }
  }

  _MusicianPlannedEvent? _parsePlannedEvent(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);

    final id = (json['id'] ?? json['_id'] ?? '').toString().trim();
    final title = (json['title'] ?? '').toString().trim();
    final dateRaw = json['date'];
    final parsedDate = dateRaw is DateTime
        ? dateRaw
        : DateTime.tryParse(dateRaw?.toString() ?? '');

    if (id.isEmpty || title.isEmpty || parsedDate == null) {
      return null;
    }

    return _MusicianPlannedEvent(
      id: id,
      title: title,
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      note: json['note']?.toString(),
    );
  }

  String _formatDateForApi(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _extractApiErrorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        final message = responseData['message']?.toString().trim();
        final errors = responseData['errors'];
        if (errors is List && errors.isNotEmpty) {
          final firstError = errors.first;
          if (firstError is Map && firstError['message'] != null) {
            final firstMessage = firstError['message'].toString().trim();
            if (firstMessage.isNotEmpty) {
              return firstMessage;
            }
          }
        }
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      final dioMessage = error.message?.trim();
      if (dioMessage != null && dioMessage.isNotEmpty) {
        return dioMessage;
      }
    }

    final rawMessage = error.toString().trim();
    if (rawMessage.isNotEmpty) {
      return rawMessage.replaceFirst('Exception: ', '');
    }

    return fallback;
  }

  void _showPageSnackBar(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _createPlannedEvent({
    required String title,
    required DateTime date,
    String? note,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return false;

    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (mounted) {
      setState(() => _isSyncingCalendarEvent = true);
    }

    try {
      final response = await ref
          .read(apiClientProvider)
          .post(
            ApiEndpoints.musicianCalendarEvents,
            data: {
              'title': trimmedTitle,
              'date': _formatDateForApi(normalizedDate),
              if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            },
          );

      final responseData = response.data;
      if (responseData is! Map || responseData['success'] != true) {
        throw Exception(
          responseData is Map
              ? (responseData['message'] ?? 'Failed to create event')
              : 'Failed to create event',
        );
      }

      final created = _parsePlannedEvent(responseData['data']);
      if (created == null) {
        throw Exception('Invalid event payload');
      }

      if (mounted) {
        setState(() {
          _plannedEvents = [
            ..._plannedEvents.where((event) => event.id != created.id),
            created,
          ]..sort((a, b) => a.date.compareTo(b.date));

          _selectedDate = normalizedDate;
          _calendarMonth = DateTime(
            normalizedDate.year,
            normalizedDate.month,
            1,
          );
        });
      }

      _lastCalendarErrorMessage = null;

      return true;
    } catch (error) {
      if (mounted) {
        final backendMessage = _extractApiErrorMessage(
          error,
          fallback: 'Failed to add calendar event.',
        );
        final message =
            backendMessage.toLowerCase() == 'musician profile not found'
            ? 'Complete your musician profile before adding calendar events.'
            : backendMessage;

        _lastCalendarErrorMessage = message;
      } else {
        _lastCalendarErrorMessage = _extractApiErrorMessage(
          error,
          fallback: 'Failed to add calendar event.',
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSyncingCalendarEvent = false);
      }
    }
  }

  Future<void> _deletePlannedEvent(String eventId) async {
    if (eventId.trim().isEmpty) return;

    if (mounted) {
      setState(() => _isSyncingCalendarEvent = true);
    }

    try {
      final response = await ref
          .read(apiClientProvider)
          .delete(ApiEndpoints.musicianCalendarEventById(eventId));

      final responseData = response.data;
      if (responseData is! Map || responseData['success'] != true) {
        throw Exception(
          responseData is Map
              ? (responseData['message'] ?? 'Failed to delete event')
              : 'Failed to delete event',
        );
      }

      if (mounted) {
        setState(() {
          _plannedEvents = _plannedEvents
              .where((event) => event.id != eventId)
              .toList();
        });

        _showPageSnackBar('Event removed from calendar.');
      }
    } catch (_) {
      if (mounted) {
        _showPageSnackBar('Failed to remove calendar event.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingCalendarEvent = false);
      }
    }
  }

  Future<void> _showAddEventDialog([DateTime? initialDate]) async {
    if (_isAddEventDialogOpen) return;
    _isAddEventDialogOpen = true;

    final titleController = TextEditingController();
    final noteController = TextEditingController();
    var eventDate = DateTime(
      (initialDate ?? _selectedDate).year,
      (initialDate ?? _selectedDate).month,
      (initialDate ?? _selectedDate).day,
    );
    String? submitError;

    try {
      final draft = await showDialog<_PlannedEventDraft>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Add Calendar Event'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        maxLength: 120,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: eventDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 730),
                                ),
                              );

                              if (picked != null) {
                                setDialogState(() {
                                  eventDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  );
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today_rounded),
                            label: const Text('Change Date'),
                          ),
                        ],
                      ),
                      if (submitError != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            submitError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final note = noteController.text.trim();

                      if (title.isEmpty) {
                        setDialogState(() {
                          submitError = 'Event title is required.';
                        });
                        return;
                      }

                      if (title.length > 120) {
                        setDialogState(() {
                          submitError =
                              'Event title must be 120 characters or less.';
                        });
                        return;
                      }

                      if (note.length > 300) {
                        setDialogState(() {
                          submitError =
                              'Event note must be 300 characters or less.';
                        });
                        return;
                      }

                      Navigator.of(dialogContext).pop(
                        _PlannedEventDraft(
                          title: title,
                          note: note,
                          date: eventDate,
                        ),
                      );
                    },
                    child: const Text('Save Event'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (draft == null) {
        return;
      }

      final created = await _createPlannedEvent(
        title: draft.title,
        date: draft.date,
        note: draft.note,
      );

      if (!mounted) {
        return;
      }

      final message = created
          ? 'Event added to calendar.'
          : (_lastCalendarErrorMessage ?? 'Failed to add calendar event.');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPageSnackBar(message);
      });
    } finally {
      _isAddEventDialogOpen = false;
      titleController.dispose();
      noteController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gigsAsync = ref.watch(gigsFeedProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final authState = ref.watch(authViewModelProvider);

    final user = authState.user;
    final displayName =
        user?.username ?? user?.email.split('@').first ?? 'Musician';

    final applications = applicationsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const [],
    );
    final appliedCount = applications.length;
    final acceptedCount = applications
        .where((a) => a.status.toLowerCase() == 'accepted')
        .length;
    final pendingCount = applications
        .where((a) => a.status.toLowerCase() == 'pending')
        .length;

    final gigs = gigsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <GigEntity>[],
    );
    final openGigCount = gigs
        .where((gig) => gig.status.toLowerCase() == 'open')
        .length;

    final gigCalendarEvents = applications
        .where((application) {
          final status = application.status.toLowerCase();
          return application.gig?.deadline != null && status == 'accepted';
        })
        .map((application) {
          final gigEntity = application.gig!;
          final location = gigEntity.location.trim();

          return _MusicianCalendarEvent(
            title: gigEntity.title,
            location: location.isEmpty ? 'Location not specified' : location,
            date: DateTime(
              gigEntity.deadline!.year,
              gigEntity.deadline!.month,
              gigEntity.deadline!.day,
            ),
            status: 'accepted',
            source: _MusicianCalendarEventSource.gig,
            gig: gigEntity,
          );
        })
        .toList();

    final plannedCalendarEvents = _plannedEvents.map((event) {
      return _MusicianCalendarEvent(
        title: event.title,
        location: 'Personal event',
        date: event.date,
        status: 'planned',
        source: _MusicianCalendarEventSource.planned,
        note: event.note,
        plannedEventId: event.id,
      );
    });

    final calendarEvents = [...gigCalendarEvents, ...plannedCalendarEvents]
      ..sort((a, b) => a.date.compareTo(b.date));

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            _HeroCard(
              displayName: displayName,
              acceptedCount: acceptedCount,
              pendingCount: pendingCount,
              openGigCount: openGigCount,
              onFindGigs: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GigsExplorePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _DashboardStatsGrid(
              cards: [
                _StatCardData(
                  label: 'Applied',
                  value: '$appliedCount',
                  icon: Icons.send_rounded,
                  color: const Color(0xFF6366F1),
                ),
                _StatCardData(
                  label: 'Accepted',
                  value: '$acceptedCount',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
                _StatCardData(
                  label: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFF59E0B),
                ),
                _StatCardData(
                  label: 'Open Gigs',
                  value: '$openGigCount',
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF1A1B61),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Recent Activities'),
            const SizedBox(height: 10),
            applicationsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyPanel(
                    title: 'No applications yet',
                    subtitle:
                        'Start browsing gigs to kickstart your musical journey.',
                    actionText: 'Browse Gigs',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GigsExplorePage(),
                        ),
                      );
                    },
                  );
                }

                final sortedItems = [...items]
                  ..sort((a, b) {
                    final first =
                        a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final second =
                        b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                    return second.compareTo(first);
                  });

                return Column(
                  children: sortedItems.take(4).map((item) {
                    final colorScheme = Theme.of(context).colorScheme;
                    final status = item.status.toLowerCase();
                    final gig = item.gig;
                    final title = gig?.title ?? 'Unknown Gig';
                    final location = gig?.location.trim() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppShellStyles.glassCard(context, radius: 18),
                      child: ListTile(
                        onTap: gig != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GigDetailsPage(gig: gig),
                                  ),
                                );
                              }
                            : null,
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          location.isEmpty ? 'No location' : location,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppShellStyles.mutedText(context),
                          ),
                        ),
                        trailing: _StatusBadge(status: status),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const _LoadingPanel(),
              error: (error, _) => _ErrorPanel(
                message: '$error',
                onRetry: () =>
                    ref.read(myApplicationsProvider.notifier).refresh(),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Gig Calendar'),
            const SizedBox(height: 10),
            _MusicianCalendarPanel(
              month: _calendarMonth,
              selectedDate: _selectedDate,
              events: calendarEvents,
              isLoadingPlannedEvents: _isLoadingPlannedEvents,
              isSyncingEvents: _isSyncingCalendarEvent,
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
              onAddEvent: (date) => _showAddEventDialog(date),
              onDeletePlannedEvent: _deletePlannedEvent,
              onOpenGigEvent: (gig) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GigDetailsPage(gig: gig)),
                );
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Latest Opportunities'),
            const SizedBox(height: 10),
            gigsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const _EmptyPanel(
                    title: 'No gigs available right now',
                    subtitle: 'Check back soon for new opportunities.',
                  );
                }

                return Column(
                  children: items.take(6).map((gig) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppShellStyles.glassCard(context, radius: 18),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GigDetailsPage(gig: gig),
                            ),
                          );
                        },
                        title: Text(
                          gig.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          gig.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppShellStyles.mutedText(context),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${gig.payRate.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              gig.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppShellStyles.mutedText(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const _LoadingPanel(),
              error: (error, _) => _ErrorPanel(
                message: '$error',
                onRetry: () => ref.read(gigsFeedProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "View All",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String displayName;
  final int acceptedCount;
  final int pendingCount;
  final int openGigCount;
  final VoidCallback onFindGigs;

  const _HeroCard({
    required this.displayName,
    required this.acceptedCount,
    required this.pendingCount,
    required this.openGigCount,
    required this.onFindGigs,
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
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
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
                'Musician Dashboard',
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
            'Welcome back, $displayName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what is happening in your journey today.",
            style: TextStyle(
              color: AppShellStyles.mutedText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(text: '$acceptedCount Accepted'),
              _InfoChip(text: '$pendingCount Pending'),
              _InfoChip(text: '$openGigCount Open Gigs'),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onFindGigs,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Find Gigs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: dark ? const Color(0xFF111111) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip({required this.text});

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
          color: colorScheme.secondary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _DashboardStatsGrid extends StatelessWidget {
  final List<_StatCardData> cards;

  const _DashboardStatsGrid({required this.cards});

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

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isAccepted = normalized == 'accepted';
    final isRejected = normalized == 'rejected';
    final isPlanned = normalized == 'planned';
    final color = isAccepted
        ? const Color(0xFF10B981)
        : isRejected
        ? const Color(0xFFEF4444)
        : isPlanned
        ? const Color(0xFF6366F1)
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
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MusicianPlannedEvent {
  final String id;
  final String title;
  final DateTime date;
  final String? note;

  const _MusicianPlannedEvent({
    required this.id,
    required this.title,
    required this.date,
    this.note,
  });
}

class _PlannedEventDraft {
  final String title;
  final String note;
  final DateTime date;

  const _PlannedEventDraft({
    required this.title,
    required this.note,
    required this.date,
  });
}

enum _MusicianCalendarEventSource { gig, planned }

class _MusicianCalendarEvent {
  final String title;
  final String location;
  final DateTime date;
  final String status;
  final _MusicianCalendarEventSource source;
  final GigEntity? gig;
  final String? note;
  final String? plannedEventId;

  const _MusicianCalendarEvent({
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.source,
    this.gig,
    this.note,
    this.plannedEventId,
  });
}

class _MusicianCalendarPanel extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final List<_MusicianCalendarEvent> events;
  final bool isLoadingPlannedEvents;
  final bool isSyncingEvents;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;
  final Future<void> Function(DateTime date) onAddEvent;
  final ValueChanged<String> onDeletePlannedEvent;
  final ValueChanged<GigEntity> onOpenGigEvent;

  const _MusicianCalendarPanel({
    required this.month,
    required this.selectedDate,
    required this.events,
    required this.isLoadingPlannedEvents,
    required this.isSyncingEvents,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    required this.onAddEvent,
    required this.onDeletePlannedEvent,
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
              TextButton.icon(
                onPressed: isSyncingEvents
                    ? null
                    : () => onAddEvent(selectedDate),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Event'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _CalendarNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
              ),
              const SizedBox(width: 6),
              _CalendarNavButton(
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
          if (isLoadingPlannedEvents) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _CalendarLegend(color: Color(0xFF10B981), label: 'Approved Gig'),
              _CalendarLegend(color: Color(0xFF6366F1), label: 'Planned Event'),
              _CalendarLegend(color: Color(0xFFF59E0B), label: 'Mixed Day'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(text: '$thisMonthCount This Month'),
              _InfoChip(text: '${upcomingEvents.length} Upcoming'),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _CalendarDayLabel(text: 'Sun'),
              _CalendarDayLabel(text: 'Mon'),
              _CalendarDayLabel(text: 'Tue'),
              _CalendarDayLabel(text: 'Wed'),
              _CalendarDayLabel(text: 'Thu'),
              _CalendarDayLabel(text: 'Fri'),
              _CalendarDayLabel(text: 'Sat'),
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

              final hasApprovedGig = dayEvents.any(
                (event) =>
                    event.source == _MusicianCalendarEventSource.gig &&
                    event.status == 'accepted',
              );
              final hasPlannedEvent = dayEvents.any(
                (event) => event.source == _MusicianCalendarEventSource.planned,
              );

              Color borderColor = Colors.grey[300]!;
              Color fillColor = Colors.grey[50]!;
              Color textColor = const Color(0xFF1A1B61);

              if (hasApprovedGig && hasPlannedEvent) {
                borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.35);
                fillColor = const Color(0xFFF59E0B).withValues(alpha: 0.12);
                textColor = const Color(0xFFB45309);
              } else if (hasApprovedGig) {
                borderColor = const Color(0xFF10B981).withValues(alpha: 0.35);
                fillColor = const Color(0xFF10B981).withValues(alpha: 0.12);
                textColor = const Color(0xFF047857);
              } else if (hasPlannedEvent) {
                borderColor = const Color(0xFF6366F1).withValues(alpha: 0.35);
                fillColor = const Color(0xFF6366F1).withValues(alpha: 0.12);
                textColor = const Color(0xFF4338CA);
              }

              if (isSelected) {
                borderColor = const Color(0xFF6366F1);
                fillColor = const Color(0xFF6366F1);
                textColor = Colors.white;
              }

              final dotColor = hasApprovedGig && hasPlannedEvent
                  ? const Color(0xFFF59E0B)
                  : hasApprovedGig
                  ? const Color(0xFF10B981)
                  : hasPlannedEvent
                  ? const Color(0xFF6366F1)
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
                                height: 6,
                                width: 6,
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
                'No gigs scheduled for this date.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            )
          else
            Column(
              children: selectedDayEvents.map((event) {
                if (event.source == _MusicianCalendarEventSource.gig &&
                    event.gig != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      color: Colors.grey[50],
                    ),
                    child: ListTile(
                      dense: true,
                      onTap: () => onOpenGigEvent(event.gig!),
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
                      trailing: _StatusBadge(status: event.status),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1B61),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.note?.isNotEmpty == true
                                  ? event.note!
                                  : 'Personal planning event',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed:
                            isSyncingEvents || event.plannedEventId == null
                            ? null
                            : () => onDeletePlannedEvent(event.plannedEventId!),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text(
            'Upcoming',
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
                final isGig = event.source == _MusicianCalendarEventSource.gig;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    dense: true,
                    onTap: isGig && event.gig != null
                        ? () => onOpenGigEvent(event.gig!)
                        : null,
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
                    trailing: isGig
                        ? _StatusBadge(status: event.status)
                        : const Text(
                            'PLANNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6366F1),
                            ),
                          ),
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

class _CalendarNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CalendarNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 30,
        width: 30,
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

class _CalendarLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _CalendarLegend({required this.color, required this.label});

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

class _CalendarDayLabel extends StatelessWidget {
  final String text;

  const _CalendarDayLabel({required this.text});

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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

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

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

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

class _EmptyPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _EmptyPanel({
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}
