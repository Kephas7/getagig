import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getagig/features/organizer/presentation/pages/create_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'edit_organizer_profile_page.dart';

class ViewOrganizerProfilePage extends ConsumerStatefulWidget {
  final String? organizerId;
  const ViewOrganizerProfilePage({super.key, this.organizerId});

  @override
  ConsumerState<ViewOrganizerProfilePage> createState() => _ViewOrganizerProfilePageState();
}

class _ViewOrganizerProfilePageState extends ConsumerState<ViewOrganizerProfilePage> {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizerProfileViewModelProvider);

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
      appBar: AppBar(
        title: const Text('Organization Profile'),
        elevation: 0,
        actions: [
          if (widget.organizerId == null &&
              profileState.status == OrganizerProfileStatus.loaded &&
              profileState.profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditOrganizerProfilePage(organizer: profileState.profile!),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(OrganizerProfileState state) {
    switch (state.status) {
      case OrganizerProfileStatus.initial:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No profile found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please create your organizer profile'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrganizerProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
              ),
            ],
          ),
        );

      case OrganizerProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case OrganizerProfileStatus.loaded:
      case OrganizerProfileStatus.updated:
        if (state.profile == null) {
          return const Center(child: Text('No profile data'));
        }
        return _buildProfileContent(state.profile!);

      case OrganizerProfileStatus.error:
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
                      .read(organizerProfileViewModelProvider.notifier)
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

  Widget _buildProfileContent(OrganizerEntity organizer) {
    final city = organizer.location['city'] ?? 'N/A';
    final country = organizer.location['country'] ?? 'N/A';
    
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.organizerId != null) {
          await ref
              .read(organizerProfileViewModelProvider.notifier)
              .getProfileById(widget.organizerId!);
        } else {
          await ref
              .read(organizerProfileViewModelProvider.notifier)
              .getProfile();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[400]!,
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
                        backgroundImage: organizer.profilePicture != null
                            ? CachedNetworkImageProvider(
                                ApiEndpoints.buildProfilePictureUrl(
                                  organizer.profilePicture,
                                ),
                              )
                            : null,
                        child: organizer.profilePicture == null
                            ? const Icon(Icons.business, size: 60, color: Colors.blue)
                            : null,
                      ),
                      if (widget.organizerId == null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _showImageSourcePicker,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
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
                    organizer.organizationName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$city, $country',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  if (organizer.bio != null && organizer.bio!.isNotEmpty) ...[
                    _buildSectionTitle('About'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          organizer.bio!,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Contact Section
                  _buildSectionTitle('Contact Information'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Contact Person'),
                          subtitle: Text(organizer.contactPerson),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(organizer.phone),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(organizer.email),
                        ),
                        if (organizer.website != null && organizer.website!.isNotEmpty) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('Website'),
                            subtitle: Text(organizer.website!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organization Details
                  _buildSectionTitle('Organization Details'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.business_center,
                          label: 'Type',
                          value: organizer.organizationType,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event Types
                  _buildSectionTitle('Event Types'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: organizer.eventTypes.map((type) {
                      return Chip(
                        label: Text(type),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Portfolio/Media
                  _buildSectionTitle('Media'),
                  Card(
                    child: Column(
                      children: [
                        _buildMediaTile(
                          icon: Icons.photo_library,
                          title: 'Photos',
                          count: organizer.photos.length,
                          onTap: () {
                            // Navigate to ManageMediaPage
                          },
                        ),
                        const Divider(height: 1),
                        _buildMediaTile(
                          icon: Icons.videocam,
                          title: 'Videos',
                          count: organizer.videos.length,
                          onTap: () {
                            // Navigate to ManageMediaPage
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verification Documents
                  _buildSectionTitle('Verification Documents'),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text('Documents'),
                      subtitle: Text('${organizer.verificationDocuments.length} files uploaded'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to handle documents
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
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
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.blue,
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

