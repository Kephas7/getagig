import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/controllers/permission_controller.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

enum OrganizerMediaType { photos, videos, documents }

class ManageOrganizerMediaPage extends ConsumerStatefulWidget {
  final OrganizerMediaType mediaType;
  final bool isOwner;

  const ManageOrganizerMediaPage({
    super.key,
    required this.mediaType,
    required this.isOwner,
  });

  @override
  ConsumerState<ManageOrganizerMediaPage> createState() =>
      _ManageOrganizerMediaPageState();
}

class _ManageOrganizerMediaPageState
    extends ConsumerState<ManageOrganizerMediaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(organizerProfileViewModelProvider);
      if (profileState.profile == null) {
        ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  String get _title {
    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return 'Photos';
      case OrganizerMediaType.videos:
        return 'Videos';
      case OrganizerMediaType.documents:
        return 'Verification Documents';
    }
  }

  IconData get _icon {
    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return Icons.photo_library;
      case OrganizerMediaType.videos:
        return Icons.videocam;
      case OrganizerMediaType.documents:
        return Icons.description;
    }
  }

  int get _maxCount {
    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return 20;
      case OrganizerMediaType.videos:
        return 10;
      case OrganizerMediaType.documents:
        return 5;
    }
  }

  Future<void> _showSourceSelectionDialog() async {
    if (!widget.isOwner) return;

    if (widget.mediaType == OrganizerMediaType.documents) {
      await _pickDocuments();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload ${widget.mediaType == OrganizerMediaType.photos ? 'Photo' : 'Video'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.12),
                  child: Icon(
                    widget.mediaType == OrganizerMediaType.photos
                        ? Icons.photo_library
                        : Icons.video_library,
                    color: Colors.blue,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: Text(
                  widget.mediaType == OrganizerMediaType.photos
                      ? 'Select one or more photos from your device'
                      : 'Select a video from your device',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(useCamera: false);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.12),
                  child: Icon(
                    widget.mediaType == OrganizerMediaType.photos
                        ? Icons.camera_alt
                        : Icons.videocam,
                    color: Colors.purple,
                  ),
                ),
                title: Text(
                  widget.mediaType == OrganizerMediaType.photos
                      ? 'Take Photo'
                      : 'Record Video',
                ),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(useCamera: true);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocuments() async {
    try {
      final permissionController = ref.read(permissionControllerProvider);
      final hasPermission = await permissionController.requestStorageWithDialog(
        context,
      );

      if (!hasPermission) return;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result == null) return;

      final files = result.paths
          .whereType<String>()
          .map((path) => File(path))
          .toList();

      if (files.isEmpty) return;

      if (!_canAdd(files.length)) {
        _showLimitMessage();
        return;
      }

      await _uploadFiles(files);
    } on FilePickerException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error selecting documents: $e');
    }
  }

  Future<void> _pickMedia({required bool useCamera}) async {
    try {
      final permissionController = ref.read(permissionControllerProvider);
      final filePickerService = ref.read(filePickerServiceProvider);

      final hasPermission = useCamera
          ? await permissionController.requestCameraWithDialog(context)
          : await permissionController.requestGalleryWithDialog(context);

      if (!hasPermission) return;

      List<File> files = [];

      switch (widget.mediaType) {
        case OrganizerMediaType.photos:
          if (useCamera) {
            final file = await filePickerService.takePhotoWithCamera();
            if (file != null) files = [file];
          } else {
            files = await filePickerService.pickMultipleImagesFromGallery();
          }
          break;
        case OrganizerMediaType.videos:
          if (useCamera) {
            final file = await filePickerService.recordVideoWithCamera();
            if (file != null) files = [file];
          } else {
            final file = await filePickerService.pickVideoFromGallery();
            if (file != null) files = [file];
          }
          break;
        case OrganizerMediaType.documents:
          return;
      }

      if (files.isEmpty) return;

      if (!_canAdd(files.length)) {
        _showLimitMessage();
        return;
      }

      await _uploadFiles(files);
    } on FilePickerException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error selecting media: $e');
    }
  }

  bool _canAdd(int incomingCount) {
    return _getCurrentMediaCount() + incomingCount <= _maxCount;
  }

  Future<void> _uploadFiles(List<File> files) async {
    final notifier = ref.read(organizerProfileViewModelProvider.notifier);

    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        await notifier.addPhotos(files);
        break;
      case OrganizerMediaType.videos:
        await notifier.addVideos(files);
        break;
      case OrganizerMediaType.documents:
        await notifier.addVerificationDocuments(files);
        break;
    }

    if (!mounted) return;
    await notifier.getProfile();
  }

  Future<void> _deleteMedia(String value) async {
    if (!widget.isOwner) return;

    final notifier = ref.read(organizerProfileViewModelProvider.notifier);

    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        await notifier.removePhoto(value);
        break;
      case OrganizerMediaType.videos:
        await notifier.removeVideo(value);
        break;
      case OrganizerMediaType.documents:
        await notifier.removeVerificationDocument(value);
        break;
    }

    if (!mounted) return;
    await notifier.getProfile();
  }

  void _showLimitMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot exceed $_maxCount ${_title.toLowerCase()}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _getCurrentMediaCount() {
    final profile = ref.read(organizerProfileViewModelProvider).profile;
    if (profile == null) return 0;

    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return profile.photos.length;
      case OrganizerMediaType.videos:
        return profile.videos.length;
      case OrganizerMediaType.documents:
        return profile.verificationDocuments.length;
    }
  }

  List<String> _getRawMediaValues(OrganizerProfileState state) {
    final profile = state.profile;
    if (profile == null) return <String>[];

    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return List<String>.from(profile.photos);
      case OrganizerMediaType.videos:
        return List<String>.from(profile.videos);
      case OrganizerMediaType.documents:
        return List<String>.from(profile.verificationDocuments);
    }
  }

  String _buildDisplayUrl(String value) {
    switch (widget.mediaType) {
      case OrganizerMediaType.photos:
        return ApiEndpoints.buildImageUrl(value);
      case OrganizerMediaType.videos:
        return ApiEndpoints.buildVideoUrl(value);
      case OrganizerMediaType.documents:
        return value;
    }
  }

  String _displayName(String value) {
    if (value.isEmpty) return 'Unknown file';
    return value.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizerProfileViewModelProvider);

    ref.listen<OrganizerProfileState>(organizerProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next.status == OrganizerProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final canAddMore = widget.isOwner && _getCurrentMediaCount() < _maxCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_getCurrentMediaCount()} / $_maxCount',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: profileState.status == OrganizerProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(profileState),
      floatingActionButton: canAddMore
          ? FloatingActionButton.extended(
              onPressed: _showSourceSelectionDialog,
              icon: Icon(
                widget.mediaType == OrganizerMediaType.photos
                    ? Icons.add_photo_alternate
                    : widget.mediaType == OrganizerMediaType.videos
                    ? Icons.videocam
                    : Icons.upload_file,
              ),
              label: Text(
                widget.mediaType == OrganizerMediaType.documents
                    ? 'Add Documents'
                    : 'Add $_title',
              ),
            )
          : null,
    );
  }

  Widget _buildBody(OrganizerProfileState state) {
    final mediaValues = _getRawMediaValues(state);

    if (mediaValues.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      },
      child: widget.mediaType == OrganizerMediaType.documents
          ? _buildDocumentList(mediaValues)
          : _buildMediaGrid(mediaValues),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey[200],
              child: Icon(_icon, size: 42, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            Text(
              'No $_title Yet',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isOwner
                  ? 'Start building your organizer portfolio'
                  : 'No media has been uploaded yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (widget.isOwner) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _showSourceSelectionDialog,
                icon: const Icon(Icons.add),
                label: Text(
                  widget.mediaType == OrganizerMediaType.documents
                      ? 'Upload Documents'
                      : 'Upload $_title',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(List<String> values) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rawValue = values[index];
        final filename = _displayName(rawValue);

        return Card(
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(rawValue),
            trailing: widget.isOwner
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(rawValue),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildMediaGrid(List<String> values) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final rawValue = values[index];
        final displayUrl = _buildDisplayUrl(rawValue);

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildGridContent(rawValue, displayUrl),
              ),
            ),
            if (widget.isOwner)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => _showDeleteConfirmation(rawValue),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGridContent(String rawValue, String displayUrl) {
    if (widget.mediaType == OrganizerMediaType.photos) {
      return CachedNetworkImage(
        imageUrl: displayUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 42, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              _displayName(rawValue),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMedia(value);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
