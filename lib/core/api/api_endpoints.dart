import 'dart:io';

import 'package:flutter/foundation.dart';
class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.1.1';
  static const int _port = 5050;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getCurrentUser = '/auth/me';

  // ============ Musicain Profile Endpoints ============
  
  static const String musicianProfile = '/musicians/profile';
  static String musicianProfileById(String id) => '/musicians/profile/$id';
  static const String musicianSearch = '/musicians/search';
  static const String musicianAvailability = '/musicians/availability';
  static const String musicianProfilePicture = '/musicians/profile-picture';
  static const String musicianPhotos = '/musicians/photos';
  static const String musicianVideos = '/musicians/videos';
  static const String musicianAudio = '/musicians/audio';


  // ============ Organizer Profile Endpoints ============
  static const String organizerProfile = '/organizers/profile';
  static String organizerProfileById(String id) => '/organizers/profile/$id';
  static const String organizerSearch = '/organizers/search';
  static const String organizerActiveStatus = '/organizers/active-status';
  static const String organizerVerify = '/organizers/verify';
  static const String organizerProfilePicture = '/organizers/profile-picture';
  static const String organizerPhotos = '/organizers/photos';
  static const String organizerVideos = '/organizers/videos';
  static const String organizerDocuments = '/organizers/verification-documents';

}
