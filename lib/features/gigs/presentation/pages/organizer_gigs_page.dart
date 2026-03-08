import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/controllers/shake_refresh_controller.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/presentation/pages/gig_applications_page.dart';
import 'package:getagig/features/messaging/presentation/pages/chat_page.dart';
import 'package:getagig/features/messaging/presentation/view_model/conversation_initiator_viewmodel.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/presentation/pages/create_gig_page.dart';
import 'package:getagig/features/gigs/presentation/pages/edit_gig_page.dart';
import 'package:getagig/features/gigs/presentation/view_model/organizer_gigs_viewmodel.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

class OrganizerGigsPage extends ConsumerStatefulWidget {
  const OrganizerGigsPage({super.key});

  @override
  ConsumerState<OrganizerGigsPage> createState() => _OrganizerGigsPageState();
}

class _OrganizerGigsPageState extends ConsumerState<OrganizerGigsPage> {
  late final ShakeRefreshController _shakeRefreshController;
  String _searchQuery = '';
  bool _isApplicantsOpen = false;
  bool _isLoadingApplicants = false;
  String? _messagingApplicantId;
  List<_ApplicantItem> _allApplicants = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      await _loadAllApplicants();
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

  Future<void> _refreshAll() async {
    await ref.read(organizerGigsProvider.notifier).refresh();
    await _loadAllApplicants();
  }

  Future<void> _refreshFromShake() async {
    await _refreshAll();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Page refreshed')));
  }

  Future<void> _loadAllApplicants() async {
    if (mounted) {
      setState(() => _isLoadingApplicants = true);
    }

    try {
      final gigs = await ref.read(organizerGigsProvider.future);
      final getGigApplications = ref.read(getGigApplicationsUseCaseProvider);

      final items = <_ApplicantItem>[];
      for (final gig in gigs) {
        final result = await getGigApplications(gig.id);
        result.fold((_) {}, (applications) {
          for (final ApplicationEntity app in applications) {
            final recipientUserId =
                (app.musicianUserId ??
                        app.musician?.userId ??
                        app.musician?.id ??
                        '')
                    .trim();
            if (recipientUserId.isEmpty) {
              continue;
            }

            items.add(
              _ApplicantItem(
                id: app.id ?? '${gig.id}-$recipientUserId',
                recipientUserId: recipientUserId,
                name: app.musician?.username ?? 'Unknown Musician',
                role: app.musician?.role ?? 'Musician',
                gigTitle: gig.title,
                gigId: gig.id,
                status: app.status,
              ),
            );
          }
        });
      }

      final statusPriority = <String, int>{
        'pending': 0,
        'accepted': 1,
        'rejected': 2,
      };

      items.sort((a, b) {
        final firstPriority = statusPriority[a.status.toLowerCase()] ?? 9;
        final secondPriority = statusPriority[b.status.toLowerCase()] ?? 9;
        if (firstPriority != secondPriority) {
          return firstPriority.compareTo(secondPriority);
        }
        return a.name.compareTo(b.name);
      });

      if (mounted) {
        setState(() {
          _allApplicants = items;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load applications overview.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingApplicants = false);
      }
    }
  }

  Future<void> _messageApplicant(_ApplicantItem applicant) async {
    setState(() => _messagingApplicantId = applicant.id);

    final conversationInitiator = ref.read(
      conversationInitiatorProvider.notifier,
    );
    final result = await conversationInitiator.startConversation(
      applicant.recipientUserId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
      (conversation) {
        final participant = conversation.participants.firstWhere(
          (p) => p.id == applicant.recipientUserId,
          orElse: () => conversation.participants.first,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversation.id ?? '',
              receiverId: applicant.recipientUserId,
              receiverName: participant.username,
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() => _messagingApplicantId = null);
    }
  }

  Future<void> _openApplicantApplications(
    _ApplicantItem applicant,
    List<GigEntity> gigs,
  ) async {
    GigEntity? targetGig;
    for (final gig in gigs) {
      if (gig.id == applicant.gigId) {
        targetGig = gig;
        break;
      }
    }

    if (targetGig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gig not found for this application.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GigApplicationsPage(gig: targetGig!)),
    );

    if (mounted) {
      await _loadAllApplicants();
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'accepted') return const Color(0xFF10B981);
    if (normalized == 'rejected') return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final gigsAsyncValue = ref.watch(organizerGigsProvider);
    final organizerProfileState = ref.watch(organizerProfileViewModelProvider);
    final organizerProfile = organizerProfileState.profile;
    final canPostGig = organizerProfile?.isVerified ?? false;
    final isVerificationPending =
        organizerProfile?.verificationRequested ?? false;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Gigs',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: canPostGig
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateGigPage(),
                            ),
                          ).then((_) => _refreshAll());
                        }
                      : isVerificationPending
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ViewOrganizerProfilePage(),
                            ),
                          );
                        },
                  icon: Icon(
                    canPostGig ? Icons.add_rounded : Icons.verified_outlined,
                    size: 20,
                  ),
                  label: Text(
                    canPostGig
                        ? 'Post Gig'
                        : isVerificationPending
                        ? 'Verification Pending'
                        : 'Verify to Post Gigs',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canPostGig
                        ? colorScheme.secondary
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: canPostGig
                        ? colorScheme.onSecondary
                        : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: gigsAsyncValue.when(
              data: (gigs) {
                final filteredGigs = gigs.where((gig) {
                  final query = _searchQuery.trim().toLowerCase();
                  if (query.isEmpty) return true;

                  final searchable = [
                    gig.title,
                    gig.description,
                    gig.eventType,
                    gig.location,
                  ].join(' ').toLowerCase();

                  return searchable.contains(query);
                }).toList();

                final applicantCountByGig = <String, int>{};
                for (final applicant in _allApplicants) {
                  applicantCountByGig[applicant.gigId] =
                      (applicantCountByGig[applicant.gigId] ?? 0) + 1;
                }

                if (gigs.isEmpty) {
                  return _EmptyGigsState(
                    canPostGig: canPostGig,
                    isVerificationPending: isVerificationPending,
                  );
                }

                final pendingCount = _allApplicants
                    .where((a) => a.status.toLowerCase() == 'pending')
                    .length;
                final acceptedCount = _allApplicants
                    .where((a) => a.status.toLowerCase() == 'accepted')
                    .length;
                final rejectedCount = _allApplicants
                    .where((a) => a.status.toLowerCase() == 'rejected')
                    .length;

                return RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search gigs...',
                          hintStyle: TextStyle(
                            color: AppShellStyles.mutedText(context),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppShellStyles.mutedText(context),
                          ),
                          filled: true,
                          fillColor: AppShellStyles.mutedSurface(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ApplicantStatChip(
                              label: 'Pending',
                              value: pendingCount,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ApplicantStatChip(
                              label: 'Accepted',
                              value: acceptedCount,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ApplicantStatChip(
                              label: 'Rejected',
                              value: rejectedCount,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          setState(
                            () => _isApplicantsOpen = !_isApplicantsOpen,
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppShellStyles.cardSurface(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppShellStyles.border(context),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people_alt_outlined, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'View All Applications',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (_isLoadingApplicants)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  _isApplicantsOpen
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_isApplicantsOpen) ...[
                        const SizedBox(height: 10),
                        if (_isLoadingApplicants)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_allApplicants.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppShellStyles.cardSurface(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppShellStyles.border(context),
                              ),
                            ),
                            child: Text(
                              'No applications yet.',
                              style: TextStyle(
                                color: AppShellStyles.mutedText(context),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppShellStyles.cardSurface(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppShellStyles.border(context),
                              ),
                            ),
                            child: Column(
                              children: _allApplicants.map((applicant) {
                                final color = _statusColor(applicant.status);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppShellStyles.border(context),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  applicant.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  applicant.gigTitle,
                                                  style: TextStyle(
                                                    color:
                                                        AppShellStyles.mutedText(
                                                          context,
                                                        ),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              applicant.status.toUpperCase(),
                                              style: TextStyle(
                                                color: color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                _openApplicantApplications(
                                                  applicant,
                                                  gigs,
                                                ),
                                            child: const Text('View'),
                                          ),
                                          const SizedBox(width: 4),
                                          TextButton(
                                            onPressed:
                                                _messagingApplicantId ==
                                                    applicant.id
                                                ? null
                                                : () => _messageApplicant(
                                                    applicant,
                                                  ),
                                            child: Text(
                                              _messagingApplicantId ==
                                                      applicant.id
                                                  ? 'Opening...'
                                                  : 'Message',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                      if (filteredGigs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppShellStyles.cardSurface(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppShellStyles.border(context),
                            ),
                          ),
                          child: Text(
                            'No gigs match your search.',
                            style: TextStyle(
                              color: AppShellStyles.mutedText(context),
                            ),
                          ),
                        )
                      else
                        ...filteredGigs.map((gig) {
                          return _OrganizerGigCard(
                            gig: gig,
                            applicantCount: applicantCountByGig[gig.id] ?? 0,
                            onDataChanged: _refreshAll,
                          );
                        }),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerGigCard extends StatelessWidget {
  final GigEntity gig;
  final int applicantCount;
  final Future<void> Function() onDataChanged;

  const _OrganizerGigCard({
    required this.gig,
    required this.applicantCount,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = gig.status.toLowerCase() == 'open';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppShellStyles.cardSurface(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!AppShellStyles.isDark(context))
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
        border: Border.all(color: AppShellStyles.border(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isOpen ? const Color(0xFF10B981) : Colors.black45)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gig.status.toUpperCase(),
                        style: TextStyle(
                          color: isOpen
                              ? const Color(0xFF10B981)
                              : AppShellStyles.mutedText(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      'Rs. ${gig.payRate.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  gig.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 16,
                      color: Colors.indigo[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gig.eventType,
                      style: TextStyle(
                        color: AppShellStyles.mutedText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$applicantCount Applicants',
                      style: TextStyle(
                        color: AppShellStyles.mutedText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (gig.id.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Gig ID is missing'),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GigApplicationsPage(gig: gig),
                        ),
                      ).then((_) => onDataChanged());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('View Applications'),
                  ),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: Colors.indigo[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditGigPage(gig: gig)),
                    ).then((_) => onDataChanged());
                  },
                ),
                const SizedBox(width: 12),
                Consumer(
                  builder: (context, ref, child) {
                    return _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: const Text('Delete Gig'),
                            content: const Text(
                              'Are you sure you want to delete this gig? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(organizerGigsProvider.notifier)
                                      .deleteGig(gig.id);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  await onDataChanged();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantItem {
  final String id;
  final String recipientUserId;
  final String name;
  final String role;
  final String gigTitle;
  final String gigId;
  final String status;

  const _ApplicantItem({
    required this.id,
    required this.recipientUserId,
    required this.name,
    required this.role,
    required this.gigTitle,
    required this.gigId,
    required this.status,
  });
}

class _ApplicantStatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ApplicantStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _EmptyGigsState extends StatelessWidget {
  final bool canPostGig;
  final bool isVerificationPending;

  const _EmptyGigsState({
    required this.canPostGig,
    required this.isVerificationPending,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              size: 80,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No gigs posted yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canPostGig
                ? 'Create your first gig posting to start receiving applications.'
                : isVerificationPending
                ? 'Your verification is under review.'
                : 'Complete verification to post your first gig.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppShellStyles.mutedText(context)),
          ),
        ],
      ),
    );
  }
}
