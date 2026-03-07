import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const String _ipAddress = String.fromEnvironment(
    'API_IP_ADDRESS',
    defaultValue: '192.168.1.15',
  );
  static const int _port = 5050;
  static const Duration _hostProbeTimeout = Duration(milliseconds: 700);

  static String? _resolvedHost;

  static Future<void> initialize() async {
    _resolvedHost = await _resolveHost();
    if (kDebugMode) {
      debugPrint('API host resolved to $_resolvedHost');
    }
  }

  static Future<String> _resolveHost() async {
    if (kIsWeb) return 'localhost';

    if (Platform.isAndroid) {
      final candidates = <String>['10.0.2.2', _ipAddress];
      final reachableHost = await _findReachableHost(candidates);
      return reachableHost ?? _ipAddress;
    }

    if (Platform.isIOS) {
      final candidates = <String>['localhost', _ipAddress];
      final reachableHost = await _findReachableHost(candidates);
      return reachableHost ?? _ipAddress;
    }

    return 'localhost';
  }

  static Future<String?> _findReachableHost(List<String> candidates) async {
    for (final host in candidates) {
      if (await _isReachable(host)) {
        return host;
      }
    }
    return null;
  }

  static Future<bool> _isReachable(String host) async {
    try {
      final socket = await Socket.connect(
        host,
        _port,
        timeout: _hostProbeTimeout,
      );
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Base URLs
  static String get _host {
    if (_resolvedHost != null && _resolvedHost!.isNotEmpty) {
      return _resolvedHost!;
    }

    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid || Platform.isIOS) return _ipAddress;
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ============ Auth Endpoints ============
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) => '/auth/reset-password/$token';
  static const String getCurrentUser = '/auth/me';

  // ============ Musicain Profile Endpoints ============
  static const String musicianProfile = '/musicians/profile';
  static String musicianProfileById(String id) => '/musicians/profile/$id';
  static const String musicianSearch = '/musicians/search';
  static const String musicianAvailability = '/musicians/availability';
  static const String musicianRequestVerification =
      '/musicians/request-verification';
  static const String musicianCalendarEvents = '/musicians/calendar-events';
  static String musicianCalendarEventById(String eventId) =>
      '/musicians/calendar-events/$eventId';
  static const String musicianProfilePicture = '/musicians/profile-picture';
  static const String musicianPhotos = '/musicians/photos';
  static const String musicianVideos = '/musicians/videos';
  static const String musicianAudio = '/musicians/audio';

  // ============ Organizer Profile Endpoints ============
  static const String organizerProfile = '/organizers/profile';
  static String organizerProfileById(String id) => '/organizers/profile/$id';
  static const String organizerSearch = '/organizers/search';
  static const String organizerActiveStatus = '/organizers/active-status';
  static const String organizerRequestVerification =
      '/organizers/request-verification';
  static const String musicianVerify = '/musicians/verify';
  static const String organizerVerify = '/organizers/verify';
  static const String organizerProfilePicture = '/organizers/profile-picture';
  static const String organizerPhotos = '/organizers/photos';
  static const String organizerVideos = '/organizers/videos';
  static const String organizerDocuments = '/organizers/verification-documents';

  // ============ Admin Endpoints ============
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';

  // ============ Gigs & Applications Endpoints ============
  static const String gigs = '/gigs';
  static String gigById(String id) => '/gigs/$id';

  static const String applications = '/applications';
  static const String myApplications = '/applications/my-applications';
  static String gigApplications(String gigId) => '/applications/gig/$gigId';
  static String updateApplicationStatus(String id) =>
      '/applications/$id/status';

  // ============ Messaging Endpoints ============
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';
  static String conversationMessages(String conversationId) =>
      '/messages/conversations/$conversationId';
  static String clearConversationMessages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static String deleteConversation(String conversationId) =>
      '/messages/conversations/$conversationId';
  static const String startConversation = '/messages/conversations/start';
  static const String sendMessage = '/messages/send';

  // ============ Notification Endpoints ============
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // ============ Image URL Constructors ============
  static String buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      final uri = Uri.parse(imageUrl);
      final path = uri.path;
      if (path.contains('/uploads/')) {
        return '$mediaServerUrl$path';
      }
      return imageUrl;
    }

    if (imageUrl.startsWith('/uploads/')) {
      return '$mediaServerUrl$imageUrl';
    }

    return '$mediaServerUrl/uploads/musicians/photos/$imageUrl';
  }

  static String buildProfilePictureUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      final uri = Uri.parse(imageUrl);
      final path = uri.path;

      if (path.contains('/uploads/')) {
        return '$mediaServerUrl$path';
      }

      return imageUrl;
    }

    if (imageUrl.startsWith('/uploads/')) {
      return '$mediaServerUrl$imageUrl';
    }

    return '$mediaServerUrl/uploads/musicians/profile/$imageUrl';
  }

  static String buildVideoUrl(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return '';

    if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
      final uri = Uri.parse(videoUrl);
      final path = uri.path;
      if (path.contains('/uploads/')) {
        return '$mediaServerUrl$path';
      }
      return videoUrl;
    }

    if (videoUrl.startsWith('/uploads/')) {
      return '$mediaServerUrl$videoUrl';
    }

    return '$mediaServerUrl/uploads/musicians/videos/$videoUrl';
  }

  static String buildAudioUrl(String? audioUrl) {
    if (audioUrl == null || audioUrl.isEmpty) return '';
    if (audioUrl.startsWith('http://') || audioUrl.startsWith('https://')) {
      final uri = Uri.parse(audioUrl);
      final path = uri.path;
      if (path.contains('/uploads/')) {
        return '$mediaServerUrl$path';
      }

      return audioUrl;
    }

    if (audioUrl.startsWith('/uploads/')) {
      return '$mediaServerUrl$audioUrl';
    }

    return '$mediaServerUrl/uploads/musicians/audio/$audioUrl';
  }
}
