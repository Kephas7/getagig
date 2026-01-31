import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/permissions/permission_service.dart';
import 'package:getagig/core/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionControllerProvider = Provider<PermissionController>((ref) {
  final permissionService = ref.watch(permissionServiceProvider);
  return PermissionController(permissionService);
});

class PermissionController {
  final PermissionService _permissionService;

  PermissionController(this._permissionService);

  Future<bool> requestCameraWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.camera,
      title: 'Camera Permission',
      message:
          'This app needs access to your camera to capture photos and videos.',
      permissionName: 'Camera',
    );
  }

  Future<bool> requestGalleryWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.photos,
      title: 'Photo Library Access',
      message: 'This app needs access to your photo library.',
      permissionName: 'Photos',
    );
  }

  Future<bool> requestStorageWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.storage,
      title: 'Storage Access',
      message: 'This app needs access to your storage to save files.',
      permissionName: 'Storage',
    );
  }

  Future<bool> requestMicrophoneWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.microphone,
      title: 'Microphone Permission',
      message: 'This app needs access to your microphone to record audio.',
      permissionName: 'Microphone',
    );
  }

  Future<bool> requestLocationWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.location,
      title: 'Location Permission',
      message: 'This app needs access to your location.',
      permissionName: 'Location',
    );
  }

  Future<bool> requestContactsWithDialog(BuildContext context) async {
    return await requestPermissionWithDialog(
      context,
      permission: Permission.contacts,
      title: 'Contacts Permission',
      message: 'This app needs access to your contacts.',
      permissionName: 'Contacts',
    );
  }

  Future<bool> requestPermissionWithDialog(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String message,
    String permissionName = 'Permission',
  }) async {
    final status = await _permissionService.getPermissionStatus(permission);

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await PermissionDialog.showPermissionResult(
          context,
          PermissionResult(
            isGranted: false,
            message:
                '$permissionName permission permanently denied. Open app settings to enable it.',
            isPermanentlyDenied: true,
          ),
          onOpenSettings: () async {
            await _permissionService.openAppSettings();
          },
        );
      }
      return false;
    }

    final result = await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: title,
      message: message,
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          permission,
          permissionName,
        );
      },
    );

    return result;
  }

  Future<bool> isPermissionGranted(Permission permission) async {
    return await _permissionService
        .getPermissionStatus(permission)
        .then((status) => status.isGranted);
  }

  Future<bool> openAppSettings() async {
    return await _permissionService.openAppSettings();
  }
}
