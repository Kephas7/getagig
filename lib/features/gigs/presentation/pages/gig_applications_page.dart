import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/dashboard/presentation/pages/chat_page.dart';
import 'package:getagig/features/dashboard/presentation/view_model/conversation_initiator_viewmodel.dart';
import 'package:getagig/features/gigs/data/repositories/application_repository.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/presentation/view_model/gig_applications_viewmodel.dart';
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

  Future<void> _messageApplicant(dynamic application) async {
    final recipientUserId = application.musician?.id?.trim();
    final applicationId = application.id ?? recipientUserId ?? 'unknown';

    if (recipientUserId == null || recipientUserId.isEmpty) {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applications',
              style: TextStyle(
                color: Color(0xFF1A1B61),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              widget.gig.title,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
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
                        color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_rounded,
                        size: 72,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1B61),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When musicians apply to this gig,\nthey will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black45,
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
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A1B61)),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final dynamic application;
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
    final app = application;
    final musicianName = app.musician?.username ?? 'Unknown Musician';
    final musicianId = app.musician?.id ?? app.musicianId;

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (musicianId != null) {
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
                        tag: 'profile_${musicianId ?? app.id}',
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.1),
                                const Color(0xFF1A1B61).withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              musicianName[0].toUpperCase(),
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Color(0xFF1A1B61),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF1A1B61),
                            ),
                          ),
                          Text(
                            'View Profile',
                            style: TextStyle(
                              color: Colors.indigo[400],
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
            const Text(
              'COVER LETTER',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black26,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Text(
                app.coverLetter,
                style: const TextStyle(
                  color: Color(0xFF1A1B61),
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
                      onPressed: () async {
                        final repo = ref.read(applicationRepositoryProvider);
                        await repo.updateStatus(app.id!, 'rejected');
                        onStatusChanged();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: BorderSide(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
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
                      onPressed: () async {
                        final repo = ref.read(applicationRepositoryProvider);
                        await repo.updateStatus(app.id!, 'accepted');
                        onStatusChanged();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
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
