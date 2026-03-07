import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/applications/data/models/application_hive_model.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:getagig/features/gigs/data/models/gig_hive_model.dart';
import 'package:getagig/features/messaging/data/models/conversation_model.dart';
import 'package:getagig/features/messaging/data/models/message_model.dart';
import 'package:getagig/features/musician/data/models/musician_hive_model.dart';
import 'package:getagig/features/notifications/data/models/notification_model.dart';
import 'package:getagig/features/organizer/data/models/organizer_hive_model.dart';
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
    if (!Hive.isAdapterRegistered(HiveTableConstant.gigTypeId)) {
      Hive.registerAdapter(GigHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.musicianProfileTypeId)) {
      Hive.registerAdapter(MusicianHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.organizerProfileTypeId)) {
      Hive.registerAdapter(OrganizerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.applicationTypeId)) {
      Hive.registerAdapter(ApplicationHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

    await Hive.openBox<ConversationModel>(HiveTableConstant.conversationTable);
    await Hive.openBox<MessageModel>(HiveTableConstant.messageTable);
    await Hive.openBox<NotificationModel>(HiveTableConstant.notificationTable);
    await Hive.openBox<GigHiveModel>(HiveTableConstant.gigTable);
    await Hive.openBox<MusicianHiveModel>(
      HiveTableConstant.musicianProfileTable,
    );
    await Hive.openBox<OrganizerHiveModel>(
      HiveTableConstant.organizerProfileTable,
    );
    await Hive.openBox<ApplicationHiveModel>(
      HiveTableConstant.applicationTable,
    );
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Box<ConversationModel> get _conversationBox =>
      Hive.box<ConversationModel>(HiveTableConstant.conversationTable);

  Box<MessageModel> get _messageBox =>
      Hive.box<MessageModel>(HiveTableConstant.messageTable);

  Box<NotificationModel> get _notificationBox =>
      Hive.box<NotificationModel>(HiveTableConstant.notificationTable);

  Box<GigHiveModel> get _gigBox =>
      Hive.box<GigHiveModel>(HiveTableConstant.gigTable);

  Box<MusicianHiveModel> get _musicianProfileBox =>
      Hive.box<MusicianHiveModel>(HiveTableConstant.musicianProfileTable);

  Box<OrganizerHiveModel> get _organizerProfileBox =>
      Hive.box<OrganizerHiveModel>(HiveTableConstant.organizerProfileTable);

  Box<ApplicationHiveModel> get _applicationBox =>
      Hive.box<ApplicationHiveModel>(HiveTableConstant.applicationTable);

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

  Future<void> clearMessagesForConversation(String conversationId) async {
    final keysToDelete = _messageBox.keys.where((key) {
      final message = _messageBox.get(key);
      return message?.conversationId == conversationId;
    }).toList();

    if (keysToDelete.isNotEmpty) {
      await _messageBox.deleteAll(keysToDelete);
    }
  }

  Future<void> updateConversationPreview({
    required String conversationId,
    String? lastMessage,
  }) async {
    final conversation = _conversationBox.get(conversationId);
    if (conversation == null) return;

    await _conversationBox.put(
      conversationId,
      conversation.copyWith(
        lastMessage: lastMessage,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await _conversationBox.delete(conversationId);
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

  Future<void> saveGigs(List<GigHiveModel> gigs, {bool replace = true}) async {
    if (replace) {
      await _gigBox.clear();
    }

    for (final gig in gigs) {
      await _gigBox.put(gig.id, gig);
    }
  }

  Future<void> upsertGig(GigHiveModel gig) async {
    await _gigBox.put(gig.id, gig);
  }

  List<GigHiveModel> getGigs({String? organizerId}) {
    final trimmedOrganizerId = organizerId?.trim();
    final values = _gigBox.values.toList();

    if (trimmedOrganizerId == null || trimmedOrganizerId.isEmpty) {
      return values;
    }

    return values
        .where((gig) => (gig.organizerId ?? '').trim() == trimmedOrganizerId)
        .toList();
  }

  GigHiveModel? getGigById(String id) {
    return _gigBox.get(id);
  }

  Future<void> deleteGig(String id) async {
    await _gigBox.delete(id);
  }

  Future<void> saveMusicianProfile(MusicianHiveModel profile) async {
    await _musicianProfileBox.put(profile.id, profile);
  }

  MusicianHiveModel? getMusicianProfileById(String id) {
    return _musicianProfileBox.get(id);
  }

  MusicianHiveModel? getMusicianProfileByUserId(String userId) {
    for (final profile in _musicianProfileBox.values) {
      if (profile.userId.trim() == userId.trim()) {
        return profile;
      }
    }
    return null;
  }

  Future<void> deleteMusicianProfileById(String id) async {
    await _musicianProfileBox.delete(id);
  }

  Future<void> deleteMusicianProfileByUserId(String userId) async {
    dynamic profileKey;
    for (final entry in _musicianProfileBox.toMap().entries) {
      final profile = entry.value;
      if (profile.userId.trim() == userId.trim()) {
        profileKey = entry.key;
        break;
      }
    }

    if (profileKey != null) {
      await _musicianProfileBox.delete(profileKey);
    }
  }

  Future<void> saveOrganizerProfile(OrganizerHiveModel profile) async {
    await _organizerProfileBox.put(profile.id, profile);
  }

  OrganizerHiveModel? getOrganizerProfileById(String id) {
    return _organizerProfileBox.get(id);
  }

  OrganizerHiveModel? getOrganizerProfileByUserId(String userId) {
    for (final profile in _organizerProfileBox.values) {
      if (profile.userId.trim() == userId.trim()) {
        return profile;
      }
    }
    return null;
  }

  Future<void> deleteOrganizerProfileById(String id) async {
    await _organizerProfileBox.delete(id);
  }

  Future<void> deleteOrganizerProfileByUserId(String userId) async {
    dynamic profileKey;
    for (final entry in _organizerProfileBox.toMap().entries) {
      final profile = entry.value;
      if (profile.userId.trim() == userId.trim()) {
        profileKey = entry.key;
        break;
      }
    }

    if (profileKey != null) {
      await _organizerProfileBox.delete(profileKey);
    }
  }

  Future<void> saveMyApplications(
    String userId,
    List<ApplicationHiveModel> applications,
  ) async {
    final normalizedUserId = userId.trim();
    final keysToDelete = _applicationBox.keys.where((key) {
      final application = _applicationBox.get(key);
      final musicianUserId = application?.musicianUserId?.trim() ?? '';
      return musicianUserId == normalizedUserId;
    }).toList();

    if (keysToDelete.isNotEmpty) {
      await _applicationBox.deleteAll(keysToDelete);
    }

    for (final application in applications) {
      await _applicationBox.put(application.id, application);
    }
  }

  Future<void> saveGigApplications(
    String gigId,
    List<ApplicationHiveModel> applications,
  ) async {
    final normalizedGigId = gigId.trim();
    final keysToDelete = _applicationBox.keys.where((key) {
      final application = _applicationBox.get(key);
      final cachedGigId = application?.gigId?.trim() ?? '';
      return cachedGigId == normalizedGigId;
    }).toList();

    if (keysToDelete.isNotEmpty) {
      await _applicationBox.deleteAll(keysToDelete);
    }

    for (final application in applications) {
      await _applicationBox.put(application.id, application);
    }
  }

  Future<void> upsertApplication(ApplicationHiveModel application) async {
    await _applicationBox.put(application.id, application);
  }

  List<ApplicationHiveModel> getMyApplications(String userId) {
    final normalizedUserId = userId.trim();

    return _applicationBox.values.where((application) {
      final musicianUserId = application.musicianUserId?.trim() ?? '';
      final musicianId = application.musicianId?.trim() ?? '';
      return musicianUserId == normalizedUserId ||
          (musicianUserId.isEmpty && musicianId == normalizedUserId);
    }).toList();
  }

  List<ApplicationHiveModel> getGigApplications(String gigId) {
    final normalizedGigId = gigId.trim();

    return _applicationBox.values
        .where(
          (application) => (application.gigId?.trim() ?? '') == normalizedGigId,
        )
        .toList();
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    final normalizedId = applicationId.trim();
    final existing = _applicationBox.get(normalizedId);

    if (existing == null) {
      return;
    }

    await _applicationBox.put(normalizedId, existing.copyWith(status: status));
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
