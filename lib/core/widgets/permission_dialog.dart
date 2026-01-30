import 'package:flutter/material.dart';
import 'package:getagig/core/services/permissions/permission_service.dart';

class PermissionDialog {
  static Future<bool> showPermissionRequest(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onRequest,
    String requestButtonText = 'Allow',
    String denyButtonText = 'Deny',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(denyButtonText),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                onRequest();
              },
              child: Text(requestButtonText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  static Future<void> showPermissionResult(
    BuildContext context,
    PermissionResult result, {
    VoidCallback? onOpenSettings,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            result.isGranted ? 'Permission Granted' : 'Permission Required',
          ),
          content: Text(result.message),
          actions: [
            if (result.isPermanentlyDenied)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onOpenSettings?.call();
                },
                child: const Text('Open Settings'),
              )
            else
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }

  static Future<bool> requestPermissionWithDialog(
    BuildContext context,
    PermissionService permissionService, {
    required String title,
    required String message,
    required Future<PermissionResult> Function() permissionRequest,
    String requestButtonText = 'Allow',
    String denyButtonText = 'Deny',
  }) async {
    final userWantsToAllow = await showPermissionRequest(
      context,
      title: title,
      message: message,
      onRequest: () {},
      requestButtonText: requestButtonText,
      denyButtonText: denyButtonText,
    );

    if (!userWantsToAllow) {
      return false;
    }

    final result = await permissionRequest();

    if (context.mounted) {
      await showPermissionResult(
        context,
        result,
        onOpenSettings: () async {
          await permissionService.openAppSettings();
        },
      );
    }

    return result.isGranted;
  }
}
