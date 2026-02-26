import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/presentation/view_model/organizer_gigs_provider.dart';
import 'package:getagig/features/gigs/presentation/pages/gig_applications_page.dart';
import 'package:getagig/features/gigs/presentation/pages/create_gig_page.dart';
import 'package:getagig/features/gigs/presentation/pages/edit_gig_page.dart';

class OrganizerGigsPage extends ConsumerWidget {
  const OrganizerGigsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gigsAsyncValue = ref.watch(organizerGigsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Gigs',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1B61),
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGigPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Post Gig'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Emerald
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: gigsAsyncValue.when(
                data: (gigs) {
                  if (gigs.isEmpty) {
                    return const _EmptyGigsState();
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(organizerGigsProvider.notifier).refresh(),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: gigs.length,
                      itemBuilder: (context, index) {
                        final gig = gigs[index];
                        return _OrganizerGigCard(gig: gig);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1B61))),
                error: (err, stack) =>
                    Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
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
  const _OrganizerGigCard({required this.gig});

  @override
  Widget build(BuildContext context) {
    bool isOpen = gig.status.toLowerCase() == 'open';

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
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isOpen ? const Color(0xFF10B981) : Colors.black45)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gig.status.toUpperCase(),
                        style: TextStyle(
                          color: isOpen ? const Color(0xFF10B981) : Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      "\$${gig.payRate}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Color(0xFF1A1B61),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  gig.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF1A1B61),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.music_note_rounded,
                        size: 16, color: Colors.indigo[400]),
                    const SizedBox(width: 4),
                    Text(
                      gig.eventType,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people_rounded,
                        size: 16, color: const Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      "12 Applicants", // Placeholder
                      style: TextStyle(
                        color: Colors.grey[600],
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
                          const SnackBar(content: Text('Error: Gig ID is missing')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GigApplicationsPage(gig: gig),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1B61),
                      foregroundColor: Colors.white,
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
                      MaterialPageRoute(
                        builder: (context) => EditGigPage(gig: gig),
                      ),
                    );
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
                                borderRadius: BorderRadius.circular(24)),
                            title: const Text('Delete Gig'),
                            content: const Text(
                                'Are you sure you want to delete this gig? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(organizerGigsProvider.notifier)
                                      .deleteGig(gig.id);
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444)),
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
          )
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _EmptyGigsState extends StatelessWidget {
  const _EmptyGigsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              size: 80,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "No gigs posted yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1B61),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start by posting your first musical event!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

