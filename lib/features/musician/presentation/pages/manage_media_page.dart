import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/core/controllers/permission_controller.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/musician/presentation/widgets/audio_gallery_viewer.dart';
import 'package:getagig/features/musician/presentation/widgets/video_gallery_viewer.dart';

enum MediaType { photos, videos, audio }

class ManageMediaPage extends ConsumerStatefulWidget {
  final MediaType mediaType;
  final List<String> mediaUrls;

  const ManageMediaPage({
    super.key,
    required this.mediaType,
    required this.mediaUrls,
  });

  @override
  ConsumerState<ManageMediaPage> createState() => _ManageMediaPageState();
}

class _ManageMediaPageState extends ConsumerState<ManageMediaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(musicianProfileViewModelProvider);
      if (profileState.profile == null) {
        ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      }
    });
  }

  String get _title {
    switch (widget.mediaType) {
      case MediaType.photos:
        return 'Photos';
      case MediaType.videos:
        return 'Videos';
      case MediaType.audio:
        return 'Audio Samples';
    }
  }

  IconData get _icon {
    switch (widget.mediaType) {
      case MediaType.photos:
        return Icons.photo_library;
      case MediaType.videos:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }

  int get _maxCount {
    switch (widget.mediaType) {
      case MediaType.photos:
        return 10;
      case MediaType.videos:
        return 5;
      case MediaType.audio:
        return 10;
    }
  }

  Future<void> _showSourceSelectionDialog(WidgetRef ref) async {
    // For audio, show different options
    if (widget.mediaType == MediaType.audio) {
      _pickAudioFiles(ref);
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
                'Upload ${widget.mediaType == MediaType.photos ? 'Photo' : 'Video'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: Icon(
                    widget.mediaType == MediaType.photos
                        ? Icons.photo_library
                        : Icons.video_library,
                    color: Colors.purple,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: Text(
                  widget.mediaType == MediaType.photos
                      ? 'Select photos from your device'
                      : 'Select a video from your device',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ref, useCamera: false);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(
                    widget.mediaType == MediaType.photos
                        ? Icons.camera_alt
                        : Icons.videocam,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  widget.mediaType == MediaType.photos
                      ? 'Take Photo'
                      : 'Record Video',
                ),
                subtitle: const Text('Use camera to capture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ref, useCamera: true);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAudioFiles(WidgetRef ref) async {
    try {
      final filePickerService = ref.read(filePickerServiceProvider);
      final files = await filePickerService.pickMultipleAudioFiles();

      if (files.isEmpty) return;

      final currentCount = _getCurrentMediaCount();

      if (currentCount + files.length > _maxCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot exceed $_maxCount audio files limit'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final notifier = ref.read(musicianProfileViewModelProvider.notifier);
      await notifier.addAudio(files);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await notifier.getProfile();
      }
    } on FilePickerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking audio files: $e')),
        );
      }
    }
  }

  Future<void> _pickMedia(WidgetRef ref, {required bool useCamera}) async {
    try {
      final permissionController = ref.read(permissionControllerProvider);
      final filePickerService = ref.read(filePickerServiceProvider);
      List<File> files = [];

      bool hasPermission = false;

      if (useCamera) {
        hasPermission = await permissionController.requestCameraWithDialog(
          context,
        );
      } else {
        hasPermission = await permissionController.requestGalleryWithDialog(
          context,
        );
      }

      if (!hasPermission) return;

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      switch (widget.mediaType) {
        case MediaType.photos:
          if (useCamera) {
            final file = await filePickerService.takePhotoWithCamera();
            if (file != null) files = [file];
          } else {
            files = await filePickerService.pickMultipleImagesFromGallery();
          }
          break;

        case MediaType.videos:
          if (useCamera) {
            final file = await filePickerService.recordVideoWithCamera();
            if (file != null) files = [file];
          } else {
            final videoFile = await filePickerService.pickVideoFromGallery();
            if (videoFile != null) files = [videoFile];
          }
          break;

        case MediaType.audio:
          return;
      }

      // Remove loading
      if (mounted) Navigator.pop(context);

      if (files.isEmpty) return;

      final currentCount = _getCurrentMediaCount();

      if (currentCount + files.length > _maxCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot exceed $_maxCount ${_title.toLowerCase()} limit',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final notifier = ref.read(musicianProfileViewModelProvider.notifier);

      switch (widget.mediaType) {
        case MediaType.photos:
          await notifier.addPhotos(files);
          break;
        case MediaType.videos:
          await notifier.addVideos(files);
          break;
        case MediaType.audio:
          await notifier.addAudio(files);
          break;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        await notifier.getProfile();
      }
    } on FilePickerException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loading if present
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loading if present
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading media: $e')));
      }
    }
  }

  int _getCurrentMediaCount() {
    final profile = ref.read(musicianProfileViewModelProvider).profile;
    if (profile == null) return 0;

    switch (widget.mediaType) {
      case MediaType.photos:
        return profile.photos.length;
      case MediaType.videos:
        return profile.videos.length;
      case MediaType.audio:
        return profile.audioSamples.length;
    }
  }

  Future<void> _deleteMedia(String url) async {
    String filename = url;
    if (url.contains('/')) {
      filename = url.split('/').last;
    }

    final notifier = ref.read(musicianProfileViewModelProvider.notifier);

    switch (widget.mediaType) {
      case MediaType.photos:
        await notifier.removePhoto(filename);
        break;
      case MediaType.videos:
        await notifier.removeVideo(filename);
        break;
      case MediaType.audio:
        await notifier.removeAudio(filename);
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Media deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openMediaViewer(int index, List<String> urls) {
    switch (widget.mediaType) {
      case MediaType.photos:
        // Use your existing social media viewer for photos
        // Or just show full screen image
        break;

      case MediaType.videos:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoGalleryViewer(
              videoUrls: urls,
              initialIndex: index,
              isOwner: true,
              onDelete: (deletedIndex) {
                if (deletedIndex < urls.length) {
                  _deleteMedia(urls[deletedIndex]);
                }
              },
            ),
          ),
        );
        break;

      case MediaType.audio:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioGalleryViewer(
              audioUrls: urls,
              initialIndex: index,
              isOwner: true,
              onDelete: (deletedIndex) {
                if (deletedIndex < urls.length) {
                  _deleteMedia(urls[deletedIndex]);
                }
              },
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(musicianProfileViewModelProvider);

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == MusicianProfileStatus.updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Media updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next.status == MusicianProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_title),
        elevation: 0,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_getCurrentMediaCount()} / $_maxCount',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: profileState.status == MusicianProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(profileState),
      floatingActionButton: _getCurrentMediaCount() < _maxCount
          ? FloatingActionButton.extended(
              onPressed: () => _showSourceSelectionDialog(ref),
              icon: Icon(
                widget.mediaType == MediaType.photos
                    ? Icons.add_photo_alternate
                    : widget.mediaType == MediaType.videos
                    ? Icons.videocam
                    : Icons.audiotrack,
              ),
              label: Text('Add $_title'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildBody(MusicianProfileState state) {
    final List<String> mediaUrls = state.profile != null
        ? _getMediaUrls(state)
        : <String>[];

    if (mediaUrls.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      },
      child: _buildMediaGrid(mediaUrls),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No $_title Yet',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your portfolio',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showSourceSelectionDialog(ref),
            icon: const Icon(Icons.add),
            label: Text('Upload $_title'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<String> mediaUrls) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: mediaUrls.length,
      itemBuilder: (context, index) {
        return _buildMediaItem(mediaUrls, index);
      },
    );
  }

  Widget _buildMediaItem(List<String> urls, int index) {
    final url = urls[index];

    return GestureDetector(
      onTap: () => _openMediaViewer(index, urls),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMediaContent(url),
            ),
          ),

          // Media type indicator
          if (widget.mediaType == MediaType.videos ||
              widget.mediaType == MediaType.audio)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.mediaType == MediaType.videos
                      ? Icons.play_arrow
                      : Icons.audiotrack,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => _showDeleteConfirmation(url),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(String url) {
    switch (widget.mediaType) {
      case MediaType.photos:
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red[400], size: 40),
              const SizedBox(height: 8),
              const Text('Failed to load', style: TextStyle(fontSize: 10)),
            ],
          ),
        );

      case MediaType.videos:
        // Show thumbnail or icon
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  url.split('/').last,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        );

      case MediaType.audio:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  url.split('/').last,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        );
    }
  }

  void _showDeleteConfirmation(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to delete this item?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMedia(url);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<String> _getMediaUrls(MusicianProfileState state) {
    final profile = state.profile;
    if (profile == null) return [];

    List<String> urls = [];

    switch (widget.mediaType) {
      case MediaType.photos:
        urls = List<String>.from(profile.photos);
        break;
      case MediaType.videos:
        urls = List<String>.from(profile.videos);
        break;
      case MediaType.audio:
        urls = List<String>.from(profile.audioSamples);
        break;
    }

    return urls.map((filename) {
      switch (widget.mediaType) {
        case MediaType.photos:
          return ApiEndpoints.buildImageUrl(filename);
        case MediaType.videos:
          return ApiEndpoints.buildVideoUrl(filename);
        case MediaType.audio:
          return ApiEndpoints.buildAudioUrl(filename);
      }
    }).toList();
  }
}
