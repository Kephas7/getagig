import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/presentation/view_model/my_applications_viewmodel.dart';
import 'package:getagig/features/gigs/presentation/pages/gig_details_page.dart';

class MyApplicationsPage extends ConsumerWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsyncValue = ref.watch(myApplicationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: applicationsAsyncValue.when(
        data: (applications) {
          final pendingCount = applications
              .where(
                (application) => application.status.toLowerCase() == 'pending',
              )
              .length;
          final acceptedCount = applications
              .where(
                (application) => application.status.toLowerCase() == 'accepted',
              )
              .length;
          final rejectedCount = applications
              .where(
                (application) => application.status.toLowerCase() == 'rejected',
              )
              .length;

          if (applications.isEmpty) {
            return _EmptyApplications(
              onBrowse: () {
                Navigator.of(context).maybePop();
              },
            );
          }

          return RefreshIndicator(
            color: colorScheme.secondary,
            onRefresh: () =>
                ref.read(myApplicationsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
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
                const SizedBox(height: 16),
                ...applications.map((application) {
                  return _ApplicationCard(application: application);
                }),
              ],
            ),
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
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationEntity application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final gig = application.gig;
    final colorScheme = Theme.of(context).colorScheme;
    final status = application.status.toLowerCase();

    Color statusColor;
    Color statusBgColor;
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF10B981);
        statusBgColor = statusColor.withValues(alpha: 0.12);
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = statusColor.withValues(alpha: 0.12);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = statusColor.withValues(alpha: 0.12);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppShellStyles.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppShellStyles.border(context)),
        boxShadow: [
          if (!AppShellStyles.isDark(context))
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (gig != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GigDetailsPage(gig: gig)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gig?.title ?? 'Unknown Gig',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _StatusChip(
                    status: status.toUpperCase(),
                    color: statusColor,
                    bgColor: statusBgColor,
                  ),
                ],
              ),
              if (gig != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppShellStyles.mutedText(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gig.location.isEmpty ? 'No location' : gig.location,
                      style: TextStyle(
                        color: AppShellStyles.mutedText(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppShellStyles.mutedText(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rs. ${gig.payRate}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Applied on: ${application.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                style: TextStyle(
                  color: AppShellStyles.mutedText(
                    context,
                  ).withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  final Color bgColor;
  const _StatusChip({
    required this.status,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyApplications extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyApplications({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_ind_outlined,
            size: 80,
            color: AppShellStyles.mutedText(context).withValues(alpha: 0.45),
          ),
          const SizedBox(height: 24),
          Text(
            'No applications yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring and applying for gigs!',
            style: TextStyle(
              color: AppShellStyles.mutedText(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onBrowse,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Browse Opportunities'),
          ),
        ],
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
