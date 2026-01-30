import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library/gallery permission
  Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request file access permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request all media permissions (camera, gallery, audio, video)
  Future<bool> requestMediaPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.photos,
      Permission.microphone,
    ];

    final statuses = await permissions.request();
    final allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  /// Request multiple specific permissions
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if gallery permission is granted
  Future<bool> isGalleryPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Get permission status
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Request permission and return user-friendly message
  Future<PermissionResult> requestPermissionWithMessage(
    Permission permission,
    String permissionName,
  ) async {
    final status = await permission.request();

    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: '$permissionName permission granted',
      );
    } else if (status.isDenied) {
      return PermissionResult(
        isGranted: false,
        message:
            '$permissionName permission denied. Please enable it in settings.',
      );
    } else if (status.isPermanentlyDenied) {
      return PermissionResult(
        isGranted: false,
        message:
            '$permissionName permission permanently denied. Open app settings to enable it.',
        isPermanentlyDenied: true,
      );
    }

    return PermissionResult(
      isGranted: false,
      message: 'Could not determine $permissionName permission status',
    );
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}

class PermissionResult {
  final bool isGranted;
  final String message;
  final bool isPermanentlyDenied;

  PermissionResult({
    required this.isGranted,
    required this.message,
    this.isPermanentlyDenied = false,
  });
}
