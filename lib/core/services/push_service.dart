import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  final notification = message.notification;
  if (notification != null) {
    final FlutterLocalNotificationsPlugin local =
        FlutterLocalNotificationsPlugin();
    try {
      await local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      await local.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'getagig_channel',
            'Get-a-Gig Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (_) {}
  }
}

class PushService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init(WidgetRef ref) async {
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOS = DarwinInitializationSettings();
      await _local.initialize(
        settings: const InitializationSettings(android: android, iOS: iOS),
      );

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final token = await messaging.getToken();
      if (token != null) {
        try {
          final api = ref.read(apiClientProvider);
          await api.post(
            '/auth/me/device-token',
            data: {'token': token, 'platform': Platform.operatingSystem},
          );
        } catch (e) {}
      }

      messaging.onTokenRefresh.listen((newToken) async {
        try {
          final api = ref.read(apiClientProvider);
          await api.post(
            '/auth/me/device-token',
            data: {'token': newToken, 'platform': Platform.operatingSystem},
          );
        } catch (e) {}
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final notification = message.notification;
          if (notification != null) {
            _local.show(
              id: 0,
              title: notification.title,
              body: notification.body,
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  'getagig_channel',
                  'Get-a-Gig Notifications',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          }
        } catch (e) {}
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    } catch (e) {}
  }
}
