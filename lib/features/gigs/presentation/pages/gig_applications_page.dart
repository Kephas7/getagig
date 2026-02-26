import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/data/repositories/application_repository_impl.dart';
import 'package:getagig/features/gigs/presentation/view_model/gig_applications_provider.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';

class GigApplicationsPage extends ConsumerWidget {
  final GigEntity gig;

  const GigApplicationsPage({super.key, required this.gig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsyncValue = ref.watch(gigApplicationsProvider(gig.id));
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
              gig.title,
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
            if (applications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
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
                      "No applications yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1B61),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "When musicians apply to this gig,\nthey will appear here.",
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

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                final musicianName =
                    app.musician?.username ?? 'Unknown Musician';
                final musicianId = app.musician?.id ?? app.musicianId;

                Color statusColor;
                Color statusBgColor;

                switch (app.status.toLowerCase()) {
                  case 'accepted':
                    statusColor = const Color(0xFF10B981);
                    statusBgColor = const Color(0xFF10B981).withOpacity(0.1);
                    break;
                  case 'rejected':
                    statusColor = const Color(0xFFEF4444);
                    statusBgColor = const Color(0xFFEF4444).withOpacity(0.1);
                    break;
                  default: // pending
                    statusColor = const Color(0xFFF59E0B);
                    statusBgColor = const Color(0xFFF59E0B).withOpacity(0.1);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                                  builder: (context) => ViewProfilePage(
                                    musicianId: musicianId,
                                  ),
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
                                            const Color(0xFF6366F1).withOpacity(0.1),
                                            const Color(0xFF1A1B61).withOpacity(0.1)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        const SizedBox(height: 20),
                        if (app.status == 'pending')
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final repo = ref.read(
                                      applicationRepositoryProvider,
                                    );
                                    await repo.updateStatus(
                                        app.id!, 'rejected');
                                    ref.invalidate(
                                      gigApplicationsProvider(gig.id),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: BorderSide(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.2)),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
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
                                    final repo = ref.read(
                                      applicationRepositoryProvider,
                                    );
                                    await repo.updateStatus(
                                        app.id!, 'accepted');
                                    ref.invalidate(
                                      gigApplicationsProvider(gig.id),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
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
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A1B61)),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

