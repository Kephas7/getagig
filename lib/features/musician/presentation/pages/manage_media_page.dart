import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/permissions/file_picker_service.dart';
import 'package:getagig/core/controllers/permission_controller.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getagig/core/api/api_endpoints.dart';

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
        print('Profile is null, fetching...');
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
    if (widget.mediaType == MediaType.audio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Audio file picker coming soon. Please use a file manager app.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ref, useCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ref, useCamera: true);
              },
            ),
          ],
        ),
      ),
    );
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

      if (!hasPermission) {
        return;
      }

      switch (widget.mediaType) {
        case MediaType.photos:
          if (useCamera) {
            final file = await filePickerService.takePhotoWithCamera();
            if (file != null) {
              files = [file];
            }
          } else {
            files = await filePickerService.pickMultipleImagesFromGallery();
          }
          break;

        case MediaType.videos:
          if (useCamera) {
            final file = await filePickerService.recordVideoWithCamera();
            if (file != null) {
              files = [file];
            }
          } else {
            final videoFile = await filePickerService.pickVideoFromGallery();
            if (videoFile != null) {
              files = [videoFile];
            }
          }
          break;

        case MediaType.audio:
          return;
      }

      if (files.isEmpty) return;

      final currentCount =
          ref.read(musicianProfileViewModelProvider).profile != null
          ? _getCurrentMediaCount()
          : 0;

      if (currentCount + files.length > _maxCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot exceed $_maxCount ${_title.toLowerCase()} limit',
              ),
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

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        await notifier.getProfile();
        print('Profile refreshed after media upload');
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
        ).showSnackBar(SnackBar(content: Text('Error picking media: $e')));
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(musicianProfileViewModelProvider);

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == MusicianProfileStatus.updated) {
        print('Photos after update: ${next.profile?.photos}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media updated successfully!')),
        );
      } else if (next.status == MusicianProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'An error occurred')),
        );
      }
    });

    print('Current profile photos: ${profileState.profile?.photos}');
    print('Profile status: ${profileState.status}');

    return Scaffold(
      appBar: AppBar(title: Text(_title), elevation: 0),
      body: profileState.status == MusicianProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildMediaGrid(profileState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSourceSelectionDialog(ref),
        icon: const Icon(Icons.add),
        label: Text('Add $_title'),
      ),
    );
  }

  Widget _buildMediaGrid(MusicianProfileState state) {
    final mediaUrls = state.profile != null
        ? _getMediaUrls(state)
        : widget.mediaUrls;

    print('Media URLs in grid: $mediaUrls');
    print('Media type: ${widget.mediaType}');
    print('Profile: ${state.profile}');

    if (mediaUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No $_title yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to add',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final notifier = ref.read(musicianProfileViewModelProvider.notifier);
        await notifier.getProfile();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          final url = mediaUrls[index];
          print('Displaying URL: $url');

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.mediaType == MediaType.photos
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) {
                            print('Loading image: $url');
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (context, url, error) {
                            print('❌ Error loading image: $url');
                            print('📍 Error details: $error');

                            String errorMsg = error.toString();
                            if (errorMsg.contains('404')) {
                              errorMsg =
                                  'Image not found (404)\n\nBackend Issue:\nFile was uploaded but not saved correctly to disk or static files not configured.';
                            }

                            return GestureDetector(
                              onLongPress: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('URL: $url')),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red[400],
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          errorMsg,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _icon,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  url.split('/').last,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => _deleteMedia(url),
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
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _getMediaUrls(MusicianProfileState state) {
    final profile = state.profile;
    if (profile == null) return [];

    List<String> urls = [];

    switch (widget.mediaType) {
      case MediaType.photos:
        urls = profile.photos;
        break;
      case MediaType.videos:
        urls = profile.videos;
        break;
      case MediaType.audio:
        urls = profile.audioSamples;
        break;
    }

    return urls
        .map((filename) => ApiEndpoints.buildImageUrl(filename))
        .toList();
  }
}
