import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/presentation/view_model/gig_applications_viewmodel.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/messaging/presentation/pages/chat_page.dart';
import 'package:getagig/features/messaging/presentation/view_model/conversation_initiator_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';

class GigApplicationsPage extends ConsumerStatefulWidget {
  final GigEntity gig;

  const GigApplicationsPage({super.key, required this.gig});

  @override
  ConsumerState<GigApplicationsPage> createState() =>
      _GigApplicationsPageState();
}

class _GigApplicationsPageState extends ConsumerState<GigApplicationsPage> {
  String? _messagingApplicationId;

  Future<void> _messageApplicant(ApplicationEntity application) async {
    final recipientUserId =
        (application.musicianUserId ??
                application.musician?.userId ??
                application.musician?.id ??
                '')
            .trim();
    final applicationId = application.id ?? recipientUserId;

    if (recipientUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find applicant user.')),
      );
      return;
    }

    setState(() => _messagingApplicationId = applicationId);

    final conversationInitiator = ref.read(
      conversationInitiatorProvider.notifier,
    );

    final result = await conversationInitiator.startConversation(
      recipientUserId,
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
          (p) => p.id == recipientUserId,
          orElse: () => conversation.participants.first,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversation.id ?? '',
              receiverId: recipientUserId,
              receiverName: participant.username,
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() => _messagingApplicationId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsyncValue = ref.watch(
      gigApplicationsProvider(widget.gig.id),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              widget.gig.title,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: applicationsAsyncValue.when(
          data: (applications) {
            final pendingCount = applications
                .where((a) => a.status.toLowerCase() == 'pending')
                .length;
            final acceptedCount = applications
                .where((a) => a.status.toLowerCase() == 'accepted')
                .length;
            final rejectedCount = applications
                .where((a) => a.status.toLowerCase() == 'rejected')
                .length;

            if (applications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_rounded,
                        size: 72,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When musicians apply to this gig,\nthey will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ApplicationStatChip(
                          label: 'Pending',
                          value: pendingCount,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ApplicationStatChip(
                          label: 'Accepted',
                          value: acceptedCount,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ApplicationStatChip(
                          label: 'Rejected',
                          value: rejectedCount,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      final appId = app.id ?? 'app_$index';

                      return _ApplicationCard(
                        application: app,
                        isMessaging: _messagingApplicationId == appId,
                        onMessage: () => _messageApplicant(app),
                        onStatusChanged: () {
                          ref.invalidate(
                            gigApplicationsProvider(widget.gig.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final ApplicationEntity application;
  final bool isMessaging;
  final VoidCallback onMessage;
  final VoidCallback onStatusChanged;

  const _ApplicationCard({
    required this.application,
    required this.isMessaging,
    required this.onMessage,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final app = application;
    final musicianName = app.musician?.username ?? 'Unknown Musician';
    final musicianId = (app.musicianId ?? app.musician?.id ?? '').trim();
    final canOpenProfile = musicianId.isNotEmpty;
    final applicationId = app.id?.trim();
    final canChangeStatus = applicationId != null && applicationId.isNotEmpty;

    Color statusColor;
    Color statusBgColor;

    switch (app.status.toLowerCase()) {
      case 'accepted':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (canOpenProfile) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewProfilePage(musicianId: musicianId),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'profile_${canOpenProfile ? musicianId : app.id}',
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.secondary.withValues(alpha: 0.14),
                                colorScheme.primary.withValues(alpha: 0.12),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              musicianName[0].toUpperCase(),
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            musicianName,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'View Profile',
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      app.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'COVER LETTER',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                app.coverLetter,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onMessage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isMessaging ? 'Opening...' : 'Message',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (app.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canChangeStatus
                          ? () async {
                              final useCase = ref.read(
                                updateApplicationStatusUseCaseProvider,
                              );
                              final result = await useCase(
                                applicationId,
                                'rejected',
                              );
                              result.fold((failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(failure.message)),
                                );
                              }, (_) => onStatusChanged());
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canChangeStatus
                          ? () async {
                              final useCase = ref.read(
                                updateApplicationStatusUseCaseProvider,
                              );
                              final result = await useCase(
                                applicationId,
                                'accepted',
                              );
                              result.fold((failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(failure.message)),
                                );
                              }, (_) => onStatusChanged());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationStatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ApplicationStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
