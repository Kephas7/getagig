import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:getagig/features/dashboard/data/models/message_model.dart';
import 'package:getagig/features/dashboard/data/repositories/message_repository.dart';
import 'package:getagig/core/services/socket_service.dart';

// Simple provider for fetching initial messages
final chatMessagesProvider = FutureProvider.family<List<MessageModel>, String>((
  ref,
  conversationId,
) async {
  final repo = ref.watch(messageRepositoryProvider);
  final result = await repo.getMessages(conversationId);
  return result.fold(
    (failure) => throw failure.message,
    (messages) => messages,
  );
});

// State notifier for managing messages with socket updates
final chatStateProvider =
    StateNotifierProvider.family<
      ChatStateNotifier,
      AsyncValue<List<MessageModel>>,
      String
    >((ref, conversationId) => ChatStateNotifier(ref, conversationId));

class ChatStateNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final Ref ref;
  final String conversationId;
  StreamSubscription? _socketSubscription;

  ChatStateNotifier(this.ref, this.conversationId)
    : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() async {
    try {
      // Join conversation on socket
      ref.read(socketServiceProvider).joinConversation(conversationId);

      // Listen to real-time incoming messages
      _socketSubscription = ref
          .read(socketServiceProvider)
          .messageStream
          .listen((data) {
            if (data['conversationId'] == conversationId) {
              final newMessage = MessageModel.fromJson(data);
              state = AsyncValue.data([...state.value ?? [], newMessage]);
            }
          });

      // Fetch initial messages
      try {
        final messages = await _fetchMessages();
        state = AsyncValue.data(messages);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<MessageModel>> _fetchMessages() async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.getMessages(conversationId);
    return result.fold(
      (failure) => throw failure.message,
      (messages) => messages,
    );
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.sendMessage(
      content: content,
      conversationId: conversationId,
      receiverId: receiverId,
    );

    result.fold(
      (failure) {
        // Handle error silently
      },
      (sentMessage) {
        // Optimistically add instead of waiting for socket loopback
        final currentMessages = state.value ?? [];
        // Prevent duplicate from socket loopback by checking ID
        if (!currentMessages.any((m) => m.id == sentMessage.id)) {
          state = AsyncValue.data([...currentMessages, sentMessage]);
        }
      },
    );
  }

  Future<void> clearConversation() async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.clearConversation(conversationId: conversationId);

    result.fold((failure) => throw Exception(failure.message), (_) {
      state = const AsyncValue.data(<MessageModel>[]);
    });
  }

  Future<void> deleteConversation() async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.deleteConversation(
      conversationId: conversationId,
    );

    result.fold((failure) => throw Exception(failure.message), (_) {
      state = const AsyncValue.data(<MessageModel>[]);
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    ref.read(socketServiceProvider).leaveConversation(conversationId);
    super.dispose();
  }
}
