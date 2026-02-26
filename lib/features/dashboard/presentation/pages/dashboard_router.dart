import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/pages/musician_dashboard_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/organizer_dashboard_page.dart';

/// Role-based dashboard router that directs users to their role's dashboard.
class DashboardRouter extends ConsumerWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.user == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final userRole = authState.user!.role.toLowerCase();

    if (userRole == 'organizer') {
      return const OrganizerDashboardPage();
    }

    // Default to musician dashboard
    return const MusicianDashboardPage();
  }
}

