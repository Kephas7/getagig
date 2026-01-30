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
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Camera Permission',
      message:
          'This app needs access to your camera to capture photos and videos.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.camera,
          'Camera',
        );
      },
    );
  }

  Future<bool> requestGalleryWithDialog(BuildContext context) async {
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Photo Library Access',
      message: 'This app needs access to your photo library.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.photos,
          'Photos',
        );
      },
    );
  }

  Future<bool> requestStorageWithDialog(BuildContext context) async {
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Storage Access',
      message: 'This app needs access to your storage to save files.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.storage,
          'Storage',
        );
      },
    );
  }

  Future<bool> requestMicrophoneWithDialog(BuildContext context) async {
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Microphone Permission',
      message: 'This app needs access to your microphone to record audio.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.microphone,
          'Microphone',
        );
      },
    );
  }

  Future<bool> requestLocationWithDialog(BuildContext context) async {
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Location Permission',
      message: 'This app needs access to your location.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.location,
          'Location',
        );
      },
    );
  }

  Future<bool> requestContactsWithDialog(BuildContext context) async {
    return await PermissionDialog.requestPermissionWithDialog(
      context,
      _permissionService,
      title: 'Contacts Permission',
      message: 'This app needs access to your contacts.',
      permissionRequest: () async {
        return await _permissionService.requestPermissionWithMessage(
          Permission.contacts,
          'Contacts',
        );
      },
    );
  }

  Future<bool> requestPermissionWithDialog(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String message,
    String permissionName = 'Permission',
  }) async {
    return await PermissionDialog.requestPermissionWithDialog(
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
