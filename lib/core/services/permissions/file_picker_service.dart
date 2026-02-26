import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'permission_service.dart';

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  final permissionService = ref.read(permissionServiceProvider);
  return FilePickerService(permissionService);
});

class FilePickerService {
  final PermissionService _permissionService;
  final ImagePicker _picker = ImagePicker();

  FilePickerService(this._permissionService);

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

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick image: $e');
    }
  }

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

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to capture photo: $e');
    }
  }

  Future<File?> pickVideoFromGallery() async {
    try {
      final hasPermission = await _permissionService.requestGalleryPermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Gallery permission denied. Please enable it in app settings.',
        );
      }

      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick video: $e');
    }
  }

  Future<File?> recordVideoWithCamera() async {
    try {
      final hasPermission = await _permissionService.requestMediaPermissions();

      if (!hasPermission) {
        throw FilePickerException(
          'Camera and microphone permissions denied. Please enable them in app settings.',
        );
      }

      final pickedFile = await _picker.pickVideo(source: ImageSource.camera);

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to record video: $e');
    }
  }

  Future<File?> pickAudioFile() async {
    try {
      final hasPermission = await _permissionService.requestStoragePermission();

      if (!hasPermission) {
        throw FilePickerException(
          'Storage permission denied. Please enable it in app settings.',
        );
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      if (e is FilePickerException) rethrow;
      throw FilePickerException('Failed to pick audio file: $e');
    }
  }

  Future<List<File>> pickMultipleAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return [];
    } catch (e) {
      throw FilePickerException('Failed to pick audio files: $e');
    }
  }

  Future<File?> pickAudioFileWithExtensions({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            allowedExtensions ?? ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw FilePickerException('Failed to pick audio file: $e');
    }
  }

  Future<File?> pickImageWithSourceSelection() async {
    return null;
  }
}

class FilePickerException implements Exception {
  final String message;

  FilePickerException(this.message);

  @override
  String toString() => message;
}
