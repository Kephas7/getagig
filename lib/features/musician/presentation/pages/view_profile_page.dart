import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getagig/features/musician/presentation/pages/manage_media_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import '../../domain/entities/musician_entity.dart';
import 'create_profile_page.dart';
import 'edit_profile_page.dart';

class ViewProfilePage extends ConsumerStatefulWidget {
  final String? musicianId;
  const ViewProfilePage({super.key, this.musicianId});

  @override
  ConsumerState<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends ConsumerState<ViewProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.musicianId != null) {
        ref
            .read(musicianProfileViewModelProvider.notifier)
            .getProfileById(widget.musicianId!);
      } else {
        ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageSourceTile(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              _imageSourceTile(
                icon: Icons.camera_alt,
                title: 'Take a Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imageSourceTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickImageFromGallery();

      if (file != null) {
        await ref
            .read(musicianProfileViewModelProvider.notifier)
            .uploadProfilePicture(file);
      }
    } on FilePickerException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error uploading image: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.takePhotoWithCamera();

      if (file != null) {
        await ref
            .read(musicianProfileViewModelProvider.notifier)
            .uploadProfilePicture(file);
      }
    } on FilePickerException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error uploading image: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestVerification() async {
    if (widget.musicianId != null) return;

    await ref
        .read(musicianProfileViewModelProvider.notifier)
        .requestVerification();

    if (!mounted) return;
    final nextState = ref.read(musicianProfileViewModelProvider);
    if (nextState.status == MusicianProfileStatus.error) {
      _showError(nextState.errorMessage ?? 'Failed to request verification');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification request sent to admin')),
    );
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Musician Profile',
          style: TextStyle(
            color: Color(0xFF1A1B61),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          if (widget.musicianId == null &&
              profileState.status == MusicianProfileStatus.loaded &&
              profileState.profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF1A1B61),
                  size: 28,
                ),
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
                  // Using push instead of pushNamed to avoid potential route mapping issues
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateProfilePage(),
                    ),
                  );
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
    final locationText = musician.location.trim().isEmpty
        ? 'N/A'
        : musician.location.trim();
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.musicianId != null) {
          await ref
              .read(musicianProfileViewModelProvider.notifier)
              .getProfileById(widget.musicianId!);
        } else {
          await ref
              .read(musicianProfileViewModelProvider.notifier)
              .getProfile();
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_${widget.musicianId ?? "my_profile"}',
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF1A1B61).withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white,
                            backgroundImage: musician.profilePicture != null
                                ? CachedNetworkImageProvider(
                                    ApiEndpoints.buildProfilePictureUrl(
                                      musician.profilePicture,
                                    ),
                                  )
                                : null,
                            child: musician.profilePicture == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 70,
                                    color: Color(0xFF1A1B61),
                                  )
                                : null,
                          ),
                        ),
                        if (widget.musicianId == null)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: InkWell(
                              onTap: _showImageSourcePicker,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1B61),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    musician.stageName,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1B61),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.indigo[300],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (musician.isAvailable
                                  ? const Color(0xFF10B981)
                                  : Colors.grey[400]!)
                              .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: musician.isAvailable
                                ? const Color(0xFF10B981)
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          musician.isAvailable
                              ? 'AVAILABLE FOR GIGS'
                              : 'CURRENTLY UNAVAILABLE',
                          style: TextStyle(
                            color: musician.isAvailable
                                ? const Color(0xFF10B981)
                                : Colors.grey[600],
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (musician.isVerified ||
                      musician.verificationRequested) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (musician.isVerified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6366F1))
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: musician.isVerified
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            musician.isVerified
                                ? 'VERIFIED ARTIST'
                                : 'VERIFICATION PENDING',
                            style: TextStyle(
                              color: musician.isVerified
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6366F1),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.musicianId == null &&
                      !musician.isVerified &&
                      !musician.verificationRequested) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _requestVerification,
                      icon: const Icon(Icons.verified_user_outlined, size: 18),
                      label: const Text('Request Verification'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (musician.bio != null && musician.bio!.isNotEmpty) ...[
                    _buildSectionTitle('BIO'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[100]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        musician.bio!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF1A1B61),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle('STATS'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.history_rounded,
                          label: 'EXPERIENCE',
                          value: '${musician.experienceYears}Y',
                          color: Colors.indigo[400]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (musician.hourlyRate != null)
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.payments_rounded,
                            label: 'HOURLY RATE',
                            value:
                                'N${musician.hourlyRate!.toStringAsFixed(0)}',
                            color: const Color(0xFF10B981),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('GENRES'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: musician.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('INSTRUMENTS'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: musician.instruments.map((instrument) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[400]!.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange[400]!.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          instrument,
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('PORTFOLIO'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey[100]!, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMediaTile(
                          icon: Icons.photo_library_rounded,
                          title: 'Photos',
                          count: musician.photos.length,
                          color: Colors.indigo[400]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.photos,
                                  mediaUrls: musician.photos.cast<String>(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMediaTile(
                          icon: Icons.videocam_rounded,
                          title: 'Videos',
                          count: musician.videos.length,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.videos,
                                  mediaUrls: musician.videos.cast<String>(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMediaTile(
                          icon: Icons.audiotrack_rounded,
                          title: 'Audio Samples',
                          count: musician.audioSamples.length,
                          color: Colors.orange[400]!,
                          isLast: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageMediaPage(
                                  mediaType: MediaType.audio,
                                  mediaUrls: musician.audioSamples
                                      .cast<String>(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (widget.musicianId == null) ...[
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
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.black26,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1B61),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black26,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTile({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF1A1B61),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count items',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.indigo[100],
              ),
            ],
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 20,
            color: Colors.grey[100],
          ),
      ],
    );
  }
}
