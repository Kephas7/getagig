import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getagig/features/musician/presentation/pages/manage_media_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import '../../domain/entities/musician_entity.dart';
import 'edit_profile_page.dart';

class ViewProfilePage extends ConsumerStatefulWidget {
  const ViewProfilePage({super.key});

  @override
  ConsumerState<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends ConsumerState<ViewProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(musicianProfileViewModelProvider.notifier).getProfile(),
    );
  }

  String _getLocationValue(
    Map<String, dynamic>? location,
    String key, [
    String defaultValue = 'N/A',
  ]) {
    if (location == null) return defaultValue;
    try {
      final value = location[key];
      return value?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final filePickerService = ref.read(filePickerServiceProvider);
      final pickedFile = await filePickerService.pickImageFromGallery();

      if (pickedFile != null) {
        await ref
            .read(musicianProfileViewModelProvider.notifier)
            .uploadProfilePicture(pickedFile);
      }
    } on FilePickerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(musicianProfileViewModelProvider);

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == MusicianProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'An error occurred')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          if (profileState.status == MusicianProfileStatus.loaded &&
              profileState.profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(musician: profileState.profile!),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(MusicianProfileState state) {
    switch (state.status) {
      case MusicianProfileStatus.initial:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No profile found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please create your musician profile'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-profile');
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
              ),
            ],
          ),
        );

      case MusicianProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case MusicianProfileStatus.loaded:
      case MusicianProfileStatus.updated:
        if (state.profile == null) {
          return const Center(child: Text('No profile data'));
        }
        return _buildProfileContent(state.profile!);

      case MusicianProfileStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(musicianProfileViewModelProvider.notifier)
                      .getProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileContent(MusicianEntity musician) {
    final city = musician.getLocationValue('city', 'N/A');
    final country = musician.getLocationValue('country', 'N/A');
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: musician.profilePicture != null
                            ? CachedNetworkImageProvider(
                                ApiEndpoints.buildProfilePictureUrl(
                                  musician.profilePicture,
                                ),
                              )
                            : null,
                        child: musician.profilePicture == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _uploadProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    musician.stageName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$city, $country',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: musician.isAvailable ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          musician.isAvailable
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          musician.isAvailable
                              ? 'Available for Gigs'
                              : 'Currently Unavailable',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (musician.bio != null && musician.bio!.isNotEmpty) ...[
                    _buildSectionTitle('About'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          musician.bio!,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _buildSectionTitle('Contact'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(musician.phone),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.work,
                          label: 'Experience',
                          value: '${musician.experienceYears} Years',
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (musician.hourlyRate != null)
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.attach_money,
                            label: 'Hourly Rate',
                            value:
                                'NPR ${musician.hourlyRate!.toStringAsFixed(0)}',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Genres'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: musician.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Instruments'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: musician.instruments.map((instrument) {
                      return Chip(
                        label: Text(instrument),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Portfolio'),
                  Card(
                    child: Column(
                      children: [
                        _buildMediaTile(
                          icon: Icons.photo_library,
                          title: 'Photos',
                          count: musician.photos.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.photos,
                                  mediaUrls: musician.photos,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMediaTile(
                          icon: Icons.videocam,
                          title: 'Videos',
                          count: musician.videos.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.videos,
                                  mediaUrls: musician.videos,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMediaTile(
                          icon: Icons.audiotrack,
                          title: 'Audio Samples',
                          count: musician.audioSamples.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.audio,
                                  mediaUrls: musician.audioSamples,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(musicianProfileViewModelProvider.notifier)
                            .updateAvailability(!musician.isAvailable);
                      },
                      icon: Icon(
                        musician.isAvailable
                            ? Icons.cancel
                            : Icons.check_circle,
                      ),
                      label: Text(
                        musician.isAvailable
                            ? 'Mark as Unavailable'
                            : 'Mark as Available',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: musician.isAvailable
                            ? Colors.grey[700]
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTile({
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}
