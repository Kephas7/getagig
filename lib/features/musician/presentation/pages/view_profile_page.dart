import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/features/musician/presentation/pages/manage_media_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  static const double _shakeThreshold = 22;
  static const Duration _shakeCooldown = Duration(seconds: 2);

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeDetectedAt;
  bool _isShakeRefreshInProgress = false;

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

    _startShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  bool get _isOwnerView => widget.musicianId == null;

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();

      if (_lastShakeDetectedAt != null &&
          now.difference(_lastShakeDetectedAt!) < _shakeCooldown) {
        return;
      }

      final magnitude = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude < _shakeThreshold) {
        return;
      }

      _lastShakeDetectedAt = now;
      _refreshProfileFromShake();
    });
  }

  Future<void> _refreshProfileFromShake() async {
    if (!mounted || _isShakeRefreshInProgress) {
      return;
    }

    _isShakeRefreshInProgress = true;
    try {
      await _refreshProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile refreshed')));
    } finally {
      _isShakeRefreshInProgress = false;
    }
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

  Future<void> _refreshProfile() async {
    if (widget.musicianId != null) {
      await ref
          .read(musicianProfileViewModelProvider.notifier)
          .getProfileById(widget.musicianId!);
      return;
    }

    await ref.read(musicianProfileViewModelProvider.notifier).getProfile();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestVerification() async {
    if (!_isOwnerView) return;

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
    final colorScheme = Theme.of(context).colorScheme;

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
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isOwnerView ? 'My Musician Profile' : 'Musician Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 21,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (_isOwnerView &&
              profileState.status == MusicianProfileStatus.loaded &&
              profileState.profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.onSurface,
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
        return _buildStatePanel(
          icon: Icons.music_note_rounded,
          title: 'No profile found',
          subtitle: 'Create your musician profile to start applying for gigs.',
          ctaLabel: 'Create Profile',
          onCtaTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProfilePage(),
              ),
            );
          },
        );

      case MusicianProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case MusicianProfileStatus.loaded:
      case MusicianProfileStatus.updated:
        if (state.profile == null) {
          return _buildStatePanel(
            icon: Icons.person_off_rounded,
            title: 'No profile data',
            subtitle: 'Try refreshing to load your profile details.',
            ctaLabel: 'Refresh',
            onCtaTap: _refreshProfile,
          );
        }
        return _buildProfileContent(state.profile!);

      case MusicianProfileStatus.error:
        return _buildStatePanel(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load profile',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          ctaLabel: 'Retry',
          onCtaTap: _refreshProfile,
          iconColor: Colors.redAccent,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileContent(MusicianEntity musician) {
    final locationText = musician.location.trim().isEmpty
        ? 'Location not provided'
        : musician.location.trim();

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildHeroHeader(musician: musician, locationText: locationText),
          const SizedBox(height: 16),
          if (musician.bio != null && musician.bio!.trim().isNotEmpty) ...[
            _buildSectionTitle('About'),
            _buildBodyCard(
              child: Text(
                musician.bio!.trim(),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          _buildSectionTitle('Highlights'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.history_rounded,
                  label: 'Experience',
                  value: '${musician.experienceYears} years',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (musician.hourlyRate != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.payments_rounded,
                    label: 'Hourly Rate',
                    value: 'N${musician.hourlyRate!.toStringAsFixed(0)}',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Genres'),
          _buildTagWrap(
            values: musician.genres,
            emptyLabel: 'No genres added yet',
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Instruments'),
          _buildTagWrap(
            values: musician.instruments,
            emptyLabel: 'No instruments added yet',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Portfolio'),
          Container(
            decoration: AppShellStyles.glassCard(context, radius: 24),
            child: Column(
              children: [
                _buildMediaTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Photos',
                  count: musician.photos.length,
                  color: Theme.of(context).colorScheme.secondary,
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
                  color: const Color(0xFFF59E0B),
                  isLast: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageMediaPage(
                          mediaType: MediaType.audio,
                          mediaUrls: musician.audioSamples.cast<String>(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isOwnerView) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(musicianProfileViewModelProvider.notifier)
                    .updateAvailability(!musician.isAvailable);
              },
              icon: Icon(
                musician.isAvailable
                    ? Icons.pause_circle_outline_rounded
                    : Icons.check_circle_rounded,
              ),
              label: Text(
                musician.isAvailable
                    ? 'Mark as Unavailable'
                    : 'Mark as Available',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: musician.isAvailable
                    ? AppShellStyles.mutedText(context)
                    : const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroHeader({
    required MusicianEntity musician,
    required String locationText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool dark = AppShellStyles.isDark(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: AppShellStyles.glassCard(
        context,
        radius: 30,
        tint: colorScheme.secondary,
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile_${widget.musicianId ?? "my_profile"}',
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.secondary.withValues(alpha: 0.92),
                        colorScheme.primary.withValues(
                          alpha: dark ? 0.76 : 0.62,
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: AppShellStyles.cardSurface(context),
                    backgroundImage: musician.profilePicture != null
                        ? CachedNetworkImageProvider(
                            ApiEndpoints.buildProfilePictureUrl(
                              musician.profilePicture,
                            ),
                          )
                        : null,
                    child: musician.profilePicture == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 58,
                            color: colorScheme.onSurface,
                          )
                        : null,
                  ),
                ),
                if (_isOwnerView)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _showImageSourcePicker,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppShellStyles.cardSurface(context),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            musician.stageName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppShellStyles.mutedText(context),
                size: 17,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  locationText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppShellStyles.mutedText(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildAvailabilityPill(musician.isAvailable),
              if (musician.isVerified || musician.verificationRequested)
                _buildVerificationPill(
                  isVerified: musician.isVerified,
                  isPending: musician.verificationRequested,
                ),
            ],
          ),
          if (_isOwnerView &&
              !musician.isVerified &&
              !musician.verificationRequested) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _requestVerification,
              icon: const Icon(Icons.verified_user_outlined, size: 18),
              label: const Text('Request Verification'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                side: BorderSide(color: colorScheme.secondary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityPill(bool available) {
    final activeColor = available
        ? const Color(0xFF10B981)
        : AppShellStyles.mutedText(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: activeColor.withValues(
          alpha: AppShellStyles.isDark(context) ? 0.22 : 0.12,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: activeColor.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            available ? 'AVAILABLE FOR GIGS' : 'CURRENTLY UNAVAILABLE',
            style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.65,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPill({
    required bool isVerified,
    required bool isPending,
  }) {
    final color = isVerified
        ? const Color(0xFF10B981)
        : Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: AppShellStyles.isDark(context) ? 0.22 : 0.12,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'VERIFIED ARTIST' : 'VERIFICATION PENDING',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.65,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePanel({
    required IconData icon,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required Future<void> Function() onCtaTap,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = AppShellStyles.mutedText(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          decoration: AppShellStyles.glassCard(context, radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: iconColor ?? colorScheme.secondary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => onCtaTap(),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppShellStyles.glassCard(context, radius: 24),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppShellStyles.mutedText(context),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTagWrap({
    required List<String> values,
    required String emptyLabel,
    required Color color,
  }) {
    if (values.isEmpty) {
      return _buildBodyCard(
        child: Text(
          emptyLabel,
          style: TextStyle(
            color: AppShellStyles.mutedText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final bool dark = AppShellStyles.isDark(context);
    return _buildBodyCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: values.map((value) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: dark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.28)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShellStyles.glassCard(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: AppShellStyles.isDark(context) ? 0.22 : 0.12,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppShellStyles.mutedText(context),
              letterSpacing: 0.3,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: AppShellStyles.isDark(context) ? 0.22 : 0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count items',
                style: TextStyle(
                  color: AppShellStyles.mutedText(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppShellStyles.mutedText(context),
              ),
            ],
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: AppShellStyles.border(context),
          ),
      ],
    );
  }
}
