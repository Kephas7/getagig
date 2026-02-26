import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/routes/app_routes.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/create_profile_page.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:getagig/features/organizer/presentation/pages/create_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';

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
      } else if (authState.user?.role == 'organizer') {
        ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final musicianState = ref.watch(musicianProfileViewModelProvider);
    final organizerState = ref.watch(organizerProfileViewModelProvider);
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

    ref.listen<OrganizerProfileState>(organizerProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (previous?.status == OrganizerProfileStatus.loading &&
          next.status == OrganizerProfileStatus.created) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(organizerProfileViewModelProvider.notifier).getProfile();
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
              _buildProfileAvatar(user, musicianState, organizerState),

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

          if (user.role == 'organizer') ...[
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            _buildOrganizerProfileSection(organizerState),
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

  Widget _buildProfileAvatar(
    dynamic user,
    MusicianProfileState musicianState,
    OrganizerProfileState organizerState,
  ) {
    String? profilePic;
    if (user.role == 'musician') {
      profilePic = musicianState.profile?.profilePicture;
    } else if (user.role == 'organizer') {
      profilePic = organizerState.profile?.profilePicture;
    }

    return CircleAvatar(
      radius: 35,
      backgroundColor: Colors.grey[200],
      backgroundImage: profilePic != null
          ? CachedNetworkImageProvider(
              ApiEndpoints.buildProfilePictureUrl(profilePic),
            )
          : null,
      child: profilePic == null
          ? const Icon(Icons.person, size: 40, color: Colors.grey)
          : null,
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

        _buildMusicianProfileStatusCard(musicianState),
      ],
    );
  }

  Widget _buildOrganizerProfileSection(OrganizerProfileState organizerState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Organizer Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (organizerState.status == OrganizerProfileStatus.loaded &&
                organizerState.profile != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewOrganizerProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        _buildOrganizerProfileStatusCard(organizerState),
      ],
    );
  }

  Widget _buildMusicianProfileStatusCard(MusicianProfileState musicianState) {
    switch (musicianState.status) {
      case MusicianProfileStatus.loading:
        return _buildLoadingCard('Loading musician profile...');

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
                        _buildStatusIcon(Colors.green),
                        const SizedBox(width: 14),
                        _buildStatusInfo('Profile Complete', profile.stageName),
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
                        _buildDivider(),
                        _buildQuickStat(
                          icon: Icons.piano,
                          label: 'Instruments',
                          value: '${profile.instruments.length}',
                          color: Colors.orange,
                        ),
                        _buildDivider(),
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
        return _buildNoMusicianProfileCard();

      case MusicianProfileStatus.error:
        if (_isNotFound(musicianState.errorMessage)) {
          return _buildNoMusicianProfileCard();
        }
        return _buildErrorCard(musicianState.errorMessage, () {
          ref.read(musicianProfileViewModelProvider.notifier).getProfile();
        });

      case MusicianProfileStatus.initial:
      default:
        return _buildNoMusicianProfileCard();
    }
  }

  Widget _buildOrganizerProfileStatusCard(OrganizerProfileState organizerState) {
    switch (organizerState.status) {
      case OrganizerProfileStatus.loading:
        return _buildLoadingCard('Loading organizer profile...');

      case OrganizerProfileStatus.loaded:
      case OrganizerProfileStatus.updated:
        if (organizerState.profile != null) {
          final profile = organizerState.profile!;
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewOrganizerProfilePage(),
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
                        _buildStatusIcon(Colors.blue),
                        const SizedBox(width: 14),
                        _buildStatusInfo(
                          'Profile Complete',
                          profile.organizationName,
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
                          icon: Icons.business_center,
                          label: 'Type',
                          value: profile.organizationType,
                          color: Colors.blue,
                        ),
                        _buildDivider(),
                        _buildQuickStat(
                          icon: Icons.event,
                          label: 'Events',
                          value: '${profile.eventTypes.length}',
                          color: Colors.green,
                        ),
                        _buildDivider(),
                        _buildQuickStat(
                          icon: Icons.collections,
                          label: 'Media',
                          value:
                              '${profile.photos.length + profile.videos.length}',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _buildNoOrganizerProfileCard();

      case OrganizerProfileStatus.error:
        if (_isNotFound(organizerState.errorMessage)) {
          return _buildNoOrganizerProfileCard();
        }
        return _buildErrorCard(organizerState.errorMessage, () {
          ref.read(organizerProfileViewModelProvider.notifier).getProfile();
        });

      case OrganizerProfileStatus.initial:
      default:
        return _buildNoOrganizerProfileCard();
    }
  }

  Widget _buildLoadingCard(String message) {
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
                message,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.check_circle, color: color, size: 28),
    );
  }

  Widget _buildStatusInfo(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  bool _isNotFound(String? errorMessage) {
    final msg = errorMessage?.toLowerCase() ?? '';
    return msg.contains('not found') ||
        msg.contains('404') ||
        msg.contains('does not exist');
  }

  Widget _buildErrorCard(String? message, VoidCallback onRetry) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.orange[700]),
            const SizedBox(height: 12),
            Text(
              message ?? 'Failed to load profile',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMusicianProfileCard() {
    return _buildNoProfileBase(
      title: 'No Musician Profile',
      description:
          'Create your profile to start getting gigs and showcase your talent',
      buttonLabel: 'Create Musician Profile',
      icon: Icons.person_add,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const CreateProfilePage()),
        );
        if (result == true && mounted) {
          ref.read(musicianProfileViewModelProvider.notifier).getProfile();
        }
      },
    );
  }

  Widget _buildNoOrganizerProfileCard() {
    return _buildNoProfileBase(
      title: 'No Organizer Profile',
      description:
          'Create your profile to start posting events and hiring talent',
      buttonLabel: 'Create Organizer Profile',
      icon: Icons.business,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateOrganizerProfilePage(),
          ),
        );
        if (result == true && mounted) {
          ref.read(organizerProfileViewModelProvider.notifier).getProfile();
        }
      },
    );
  }

  Widget _buildNoProfileBase({
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
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
              child: Icon(icon, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
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
                onPressed: onPressed,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(buttonLabel),
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

