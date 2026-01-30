import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'permission_service.dart';

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  final permissionService = ref.read(permissionServiceProvider);
  return FilePickerService(permissionService);
});

class FilePickerService {
  final PermissionService _permissionService;
  final ImagePicker _picker = ImagePicker();

  FilePickerService(this._permissionService);

  /// Pick image from gallery with permission check
  Future<File?> pickImageFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestGalleryPermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Gallery permission denied. Please enable it in app settings.',
        );
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick image: $e');
    }
  }

  /// Pick multiple images from gallery with permission check
  Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestGalleryPermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Gallery permission denied. Please enable it in app settings.',
        );
      }

      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick images: $e');
    }
  }

  /// Take photo using camera with permission check
  Future<File?> takePhotoWithCamera() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Camera permission denied. Please enable it in app settings.',
        );
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to capture photo: $e');
    }
  }

  /// Pick video from gallery with permission check
  Future<File?> pickVideoFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestGalleryPermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Gallery permission denied. Please enable it in app settings.',
        );
      }

      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick video: $e');
    }
  }

  /// Record video using camera with permission check
  Future<File?> recordVideoWithCamera() async {
    try {
      final hasPermission = await _permissionService.requestMediaPermissions();

      if (!hasPermission) {
        throw FilePickerException(
          'Camera and microphone permissions denied. Please enable them in app settings.',
        );
      }

      final pickedFile = await _picker.pickVideo(source: ImageSource.camera);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to record video: $e');
    }
  }

  /// Show image source selection dialog
  Future<File?> pickImageWithSourceSelection() async {
    // Return null to let the UI handle the selection dialog
    // This should be called from a dialog that shows camera/gallery options
    return null;
  }
}

class FilePickerException implements Exception {
  final String message;

  FilePickerException(this.message);

  @override
  String toString() => message;
}
