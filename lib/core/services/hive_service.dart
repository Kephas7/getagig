import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:getagig/features/dashboard/data/models/conversation_model.dart';
import 'package:getagig/features/dashboard/data/models/message_model.dart';
import 'package:getagig/features/dashboard/data/models/notification_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();

    await Hive.initFlutter(directory.path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.conversationTypeId)) {
      Hive.registerAdapter(ConversationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.messageTypeId)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.notificationTypeId)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.authApiTypeId)) {
      Hive.registerAdapter(AuthApiModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

    await Hive.openBox<ConversationModel>(HiveTableConstant.conversationTable);
    await Hive.openBox<MessageModel>(HiveTableConstant.messageTable);
    await Hive.openBox<NotificationModel>(HiveTableConstant.notificationTable);
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Box<ConversationModel> get _conversationBox =>
      Hive.box<ConversationModel>(HiveTableConstant.conversationTable);

  Box<MessageModel> get _messageBox =>
      Hive.box<MessageModel>(HiveTableConstant.messageTable);

  Box<NotificationModel> get _notificationBox =>
      Hive.box<NotificationModel>(HiveTableConstant.notificationTable);

  Future<void> saveConversations(List<ConversationModel> conversations) async {
    await _conversationBox.clear();
    for (var conv in conversations) {
      if (conv.id != null) {
        await _conversationBox.put(conv.id, conv);
      }
    }
  }

  List<ConversationModel> getConversations() {
    return _conversationBox.values.toList();
  }

  Future<void> saveMessages(List<MessageModel> messages) async {
    for (var msg in messages) {
      if (msg.id != null) {
        await _messageBox.put(msg.id, msg);
      }
    }
  }

  List<MessageModel> getMessages(String conversationId) {
    return _messageBox.values
        .where((m) => m.conversationId == conversationId)
        .toList();
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    await _notificationBox.clear();
    for (var notif in notifications) {
      if (notif.id != null) {
        await _notificationBox.put(notif.id!, notif);
      }
    }
  }

  List<NotificationModel> getNotifications() {
    return _notificationBox.values.toList();
  }

  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.userId, user);
    return user;
  }

  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  AuthHiveModel? getUserById(String userId) {
    return _authBox.get(userId);
  }

  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateUser(AuthHiveModel user) async {
    if (!_authBox.containsKey(user.userId)) return false;

    await _authBox.put(user.userId, user);
    return true;
  }

  Future<void> deleteUser(String userId) async {
    await _authBox.delete(userId);
  }

  Future<void> logout() async {}
}
