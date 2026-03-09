import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestGalleryPermission() async {
    final status = await ph.Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await ph.Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestMediaPermissions() async {
    final permissions = [
      ph.Permission.camera,
      ph.Permission.photos,
      ph.Permission.microphone,
    ];

    final statuses = await permissions.request();
    final allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissions(
    List<ph.Permission> permissions,
  ) async {
    return await permissions.request();
  }

  Future<bool> isCameraPermissionGranted() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isGalleryPermissionGranted() async {
    final status = await ph.Permission.photos.status;
    return status.isGranted;
  }

  Future<bool> isStoragePermissionGranted() async {
    final status = await ph.Permission.storage.status;
    return status.isGranted;
  }

  Future<ph.PermissionStatus> getPermissionStatus(
    ph.Permission permission,
  ) async {
    return await permission.status;
  }

  Future<PermissionResult> requestPermissionWithMessage(
    ph.Permission permission,
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

  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
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
