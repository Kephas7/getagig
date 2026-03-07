import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/features/gigs/presentation/pages/create_gig_page.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/presentation/pages/create_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

import 'edit_organizer_profile_page.dart';
import 'manage_organizer_media_page.dart';

class ViewOrganizerProfilePage extends ConsumerStatefulWidget {
  final String? organizerId;
  const ViewOrganizerProfilePage({super.key, this.organizerId});

  @override
  ConsumerState<ViewOrganizerProfilePage> createState() =>
      _ViewOrganizerProfilePageState();
}

class _ViewOrganizerProfilePageState
    extends ConsumerState<ViewOrganizerProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.organizerId != null) {
        ref
            .read(organizerProfileViewModelProvider.notifier)
            .getProfileById(widget.organizerId!);
      } else {
        ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  bool get _isOwnerView => widget.organizerId == null;

  Future<void> _refreshProfile() async {
    if (widget.organizerId != null) {
      await ref
          .read(organizerProfileViewModelProvider.notifier)
          .getProfileById(widget.organizerId!);
      return;
    }

    await ref.read(organizerProfileViewModelProvider.notifier).getProfile();
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
            .read(organizerProfileViewModelProvider.notifier)
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
            .read(organizerProfileViewModelProvider.notifier)
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
    if (!_isOwnerView) return;

    await ref
        .read(organizerProfileViewModelProvider.notifier)
        .requestVerification();

    if (!mounted) return;
    final nextState = ref.read(organizerProfileViewModelProvider);
    if (nextState.status == OrganizerProfileStatus.error) {
      _showError(nextState.errorMessage ?? 'Failed to request verification');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification request sent to admin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizerProfileViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<OrganizerProfileState>(organizerProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == OrganizerProfileStatus.error) {
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
          _isOwnerView ? 'My Organization Profile' : 'Organization Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 21,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (_isOwnerView &&
              profileState.status == OrganizerProfileStatus.loaded &&
              profileState.profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.onSurface,
                  size: 27,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditOrganizerProfilePage(
                        organizer: profileState.profile!,
                      ),
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

  Widget _buildBody(OrganizerProfileState state) {
    switch (state.status) {
      case OrganizerProfileStatus.initial:
        return _buildStatePanel(
          icon: Icons.business_rounded,
          title: 'No profile found',
          subtitle:
              'Create your organizer profile to post gigs and manage applicants.',
          ctaLabel: 'Create Profile',
          onCtaTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateOrganizerProfilePage(),
              ),
            );
          },
        );

      case OrganizerProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case OrganizerProfileStatus.loaded:
      case OrganizerProfileStatus.updated:
        if (state.profile == null) {
          return _buildStatePanel(
            icon: Icons.person_off_rounded,
            title: 'No profile data',
            subtitle: 'Try refreshing to load your organization details.',
            ctaLabel: 'Refresh',
            onCtaTap: _refreshProfile,
          );
        }
        return _buildProfileContent(state.profile!);

      case OrganizerProfileStatus.error:
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

  Widget _buildProfileContent(OrganizerEntity organizer) {
    final locationText = organizer.location.trim().isEmpty
        ? 'Location not provided'
        : organizer.location.trim();

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildHeroHeader(organizer: organizer, locationText: locationText),
          const SizedBox(height: 16),
          if (_isOwnerView) ...[
            _buildSectionTitle('Post Gig Access'),
            _buildPostGigAccessCard(organizer),
            const SizedBox(height: 18),
          ],
          if (organizer.bio != null && organizer.bio!.trim().isNotEmpty) ...[
            _buildSectionTitle('About'),
            _buildBodyCard(
              child: Text(
                organizer.bio!.trim(),
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
          _buildSectionTitle('Contact'),
          _buildBodyCard(
            child: Column(
              children: [
                _buildContactTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Contact Person',
                  value: organizer.contactPerson,
                ),
                _buildInnerDivider(),
                _buildContactTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: organizer.phone,
                ),
                _buildInnerDivider(),
                _buildContactTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: organizer.email,
                ),
                if (organizer.website != null &&
                    organizer.website!.isNotEmpty) ...[
                  _buildInnerDivider(),
                  _buildContactTile(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: organizer.website!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Organization Details'),
          _buildStatCard(
            icon: Icons.business_center_rounded,
            label: 'Organization Type',
            value: organizer.organizationType,
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Event Types'),
          _buildTagWrap(
            values: organizer.eventTypes,
            emptyLabel: 'No event types added yet',
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Media'),
          Container(
            decoration: AppShellStyles.glassCard(context, radius: 24),
            child: Column(
              children: [
                _buildMediaTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Photos',
                  count: organizer.photos.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageOrganizerMediaPage(
                          mediaType: OrganizerMediaType.photos,
                          isOwner: _isOwnerView,
                        ),
                      ),
                    );
                  },
                ),
                _buildInnerDivider(indent: 64),
                _buildMediaTile(
                  icon: Icons.videocam_rounded,
                  title: 'Videos',
                  count: organizer.videos.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageOrganizerMediaPage(
                          mediaType: OrganizerMediaType.videos,
                          isOwner: _isOwnerView,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Verification Documents'),
          Container(
            decoration: AppShellStyles.glassCard(context, radius: 20),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text(
                'Documents',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${organizer.verificationDocuments.length} files uploaded',
                style: TextStyle(color: AppShellStyles.mutedText(context)),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppShellStyles.mutedText(context),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageOrganizerMediaPage(
                      mediaType: OrganizerMediaType.documents,
                      isOwner: _isOwnerView,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader({
    required OrganizerEntity organizer,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.92),
                      colorScheme.primary.withValues(alpha: dark ? 0.76 : 0.62),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: AppShellStyles.cardSurface(context),
                  backgroundImage: organizer.profilePicture != null
                      ? CachedNetworkImageProvider(
                          ApiEndpoints.buildProfilePictureUrl(
                            organizer.profilePicture,
                          ),
                        )
                      : null,
                  child: organizer.profilePicture == null
                      ? Icon(
                          Icons.business_rounded,
                          size: 56,
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
          const SizedBox(height: 15),
          Text(
            organizer.organizationName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
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
          if (organizer.isVerified || organizer.verificationRequested)
            _buildVerificationPill(
              isVerified: organizer.isVerified,
              isPending: organizer.verificationRequested,
            ),
          if (_isOwnerView &&
              !organizer.isVerified &&
              !organizer.verificationRequested) ...[
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
            isVerified ? 'VERIFIED ORGANIZER' : 'VERIFICATION PENDING',
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

  Widget _buildPostGigAccessCard(OrganizerEntity organizer) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool canPost = organizer.isVerified;

    final title = canPost
        ? 'Verified organizer'
        : organizer.verificationRequested
        ? 'Verification under review'
        : 'Verification required';

    final description = canPost
        ? 'You can post gigs and hire top musical talent on Get-a-Gig.'
        : organizer.verificationRequested
        ? 'Your request has been sent to admin. We will notify you once it is reviewed.'
        : 'Request verification to increase trust and improve hiring visibility.';

    return _buildBodyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: AppShellStyles.mutedText(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canPost
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGigPage(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Post a Gig'),
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

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: colorScheme.secondary),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppShellStyles.mutedText(context),
          letterSpacing: 0.2,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppShellStyles.glassCard(context, radius: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppShellStyles.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildMediaTile({
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: AppShellStyles.mutedText(context),
              fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildInnerDivider({double indent = 0}) {
    return Divider(
      height: 1,
      indent: indent,
      color: AppShellStyles.border(context),
    );
  }
}
