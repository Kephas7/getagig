import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

final socketServiceProvider = Provider<SocketService>((ref) {
  final socketService = SocketService();

  // Connect using the persisted auth token (survives app restarts)
  Future.microtask(() async {
    final session = ref.read(userSessionServiceProvider);
    final token = await session.getToken();

    if (token != null && token.isNotEmpty) {
      socketService.connect(token);
    } else {
      socketService.disconnect();
    }
  });

  // Ensure socket wraps up when provider gets destroyed
  ref.onDispose(() {
    socketService.disconnect();
  });

  return socketService;
});

class SocketService {
  IO.Socket? _socket;

  // Streams for external UI widgets to listen to
  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(ApiEndpoints.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket Connected');
    });

    _socket!.on('newMessage', (data) {
      _messageStreamController.add(data);
    });

    _socket!.on('receiveNotification', (data) {
      _notificationStreamController.add(data);
    });

    _socket!.onDisconnect((_) => print('Socket Disconnected'));
    _socket!.onError((err) => print('Socket Error: $err'));
  }

  void joinConversation(String conversationId) {
    _socket?.emit('joinConversation', conversationId);
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leaveConversation', conversationId);
  }

  /// Send a notification to a specific user
  /// Notifies the receiver about messages, gig updates, or other events
  void sendNotification({
    required String userId,
    required String type,
    required String title,
    required String content,
    String? relatedId,
  }) {
    _socket?.emit('sendNotification', {
      'userId': userId,
      'type': type, // 'message', 'gig_update', 'application', etc.
      'title': title,
      'content': content,
      'relatedId': relatedId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
