import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/routes/app_routes.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/create_profile_page.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authViewModelProvider);
      if (authState.user?.role == 'musician') {
        ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final musicianState = ref.watch(musicianProfileViewModelProvider);
    final user = authState.user;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        AppRoutes.pushAndRemoveUntil(context, const LoginPage());
      }
    });

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (previous?.status == MusicianProfileStatus.loading &&
          next.status == MusicianProfileStatus.created) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(musicianProfileViewModelProvider.notifier).getProfile();
          }
        });
      }
    });

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          _profileItem("Email", user.email),

          if (user.role == 'musician') ...[
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            _buildMusicianProfileSection(musicianState),
          ],

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicianProfileSection(MusicianProfileState musicianState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Musician Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (musicianState.status == MusicianProfileStatus.loaded &&
                musicianState.profile != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        _buildProfileStatusCard(musicianState),
      ],
    );
  }

  Widget _buildProfileStatusCard(MusicianProfileState musicianState) {
    switch (musicianState.status) {
      case MusicianProfileStatus.loading:
        return Card(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading profile...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );

      case MusicianProfileStatus.loaded:
      case MusicianProfileStatus.updated:
        if (musicianState.profile != null) {
          final profile = musicianState.profile!;
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewProfilePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Profile Complete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.stageName,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                          icon: Icons.music_note,
                          label: 'Genres',
                          value: '${profile.genres.length}',
                          color: Colors.purple,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        _buildQuickStat(
                          icon: Icons.piano,
                          label: 'Instruments',
                          value: '${profile.instruments.length}',
                          color: Colors.orange,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        _buildQuickStat(
                          icon: Icons.collections,
                          label: 'Media',
                          value:
                              '${profile.photos.length + profile.videos.length + profile.audioSamples.length}',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _buildNoProfileCard();

      case MusicianProfileStatus.error:
        final errorMsg = musicianState.errorMessage?.toLowerCase() ?? '';
        final isNotFoundError =
            errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('does not exist');

        if (isNotFoundError) {
          return _buildNoProfileCard();
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.orange[700]),
                const SizedBox(height: 12),
                Text(
                  musicianState.errorMessage ?? 'Failed to load profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(musicianProfileViewModelProvider.notifier)
                        .getProfile();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case MusicianProfileStatus.initial:
      default:
        return _buildNoProfileCard();
    }
  }

  Widget _buildNoProfileCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Musician Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your profile to start getting gigs and showcase your talent',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateProfilePage(),
                    ),
                  );

                  if (result == true && mounted) {
                    ref
                        .read(musicianProfileViewModelProvider.notifier)
                        .getProfile();
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Musician Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 26, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'musician':
        return Colors.purple;
      case 'organizer':
        return Colors.blue;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authViewModelProvider.notifier).logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
