import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/app.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/core/services/push_service.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and register background message handler
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // initialize Hive or other services if needed
  await HiveService().init();

  // Auto-resolve backend host (emulator vs physical device)
  await ApiEndpoints.initialize();

  // Initialize SharedPreferences : because this is async operation
  // but riverpod providers are sync so we need to initialize it here
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],

      child: const App(),
    ),
  );
}
