import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    if (user.role == 'musician') {
      return const ViewProfilePage(showAppBar: false);
    }

    if (user.role == 'organizer') {
      return const ViewOrganizerProfilePage(showAppBar: false);
    }

    return const Center(child: Text('Unsupported user role'));
  }
}
