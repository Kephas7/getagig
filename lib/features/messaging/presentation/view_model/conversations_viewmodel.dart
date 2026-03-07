import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/socket_service.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/messaging/data/models/conversation_model.dart';
import 'package:getagig/features/messaging/data/repositories/message_repository.dart';

final conversationsProvider =
    AsyncNotifierProvider.autoDispose<
      ConversationsNotifier,
      List<ConversationModel>
    >(() {
      return ConversationsNotifier();
    });

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  @override
  Future<List<ConversationModel>> build() async {
    final currentUserId = ref.watch(
      authViewModelProvider.select((state) {
        final id = (state.user?.userId ?? state.user?.id)?.trim();
        return (id == null || id.isEmpty) ? null : id;
      }),
    );

    if (currentUserId == null) {
      return const <ConversationModel>[];
    }

    _messageSubscription ??= ref
        .read(socketServiceProvider)
        .messageStream
        .listen(_handleIncomingMessage);

    ref.onDispose(() {
      _messageSubscription?.cancel();
      _messageSubscription = null;
    });

    return _fetchConversations(currentUserId);
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    final currentUserId =
        (ref.read(authViewModelProvider).user?.userId ??
                ref.read(authViewModelProvider).user?.id)
            ?.trim();
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    final conversationId = data['conversationId']?.toString();
    final content = data['content']?.toString().trim();

    if (conversationId == null ||
        conversationId.isEmpty ||
        content == null ||
        content.isEmpty) {
      return;
    }

    final current = state.value;
    if (current == null) return;

    final next = [...current];
    final index = next.indexWhere(
      (conversation) => conversation.id == conversationId,
    );

    if (index == -1) {
      unawaited(refresh());
      return;
    }

    final updatedConversation = next[index].copyWith(
      lastMessage: content,
      updatedAt: DateTime.now(),
    );

    next.removeAt(index);
    next.insert(0, updatedConversation);
    state = AsyncValue.data(next);
  }

  Future<List<ConversationModel>> _fetchConversations(
    String currentUserId,
  ) async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.getConversations();
    return result.fold(
      (failure) => throw failure.message,
      (conversations) => conversations
          .where(
            (conversation) => conversation.participants.any(
              (participant) => (participant.id ?? '').trim() == currentUserId,
            ),
          )
          .toList(),
    );
  }

  Future<void> refresh() async {
    final currentUserId =
        (ref.read(authViewModelProvider).user?.userId ??
                ref.read(authViewModelProvider).user?.id)
            ?.trim();

    if (currentUserId == null || currentUserId.isEmpty) {
      state = const AsyncValue.data(<ConversationModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchConversations(currentUserId));
  }
}
