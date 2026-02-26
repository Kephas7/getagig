import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/dashboard/data/models/conversation_model.dart';
import 'package:getagig/features/dashboard/data/repositories/message_repository.dart';

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(() {
  return ConversationsNotifier();
});

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  Future<List<ConversationModel>> build() async {
    return _fetchConversations();
  }

  Future<List<ConversationModel>> _fetchConversations() async {
    final repo = ref.read(messageRepositoryProvider);
    final result = await repo.getConversations();
    return result.fold(
      (failure) => throw failure.message,
      (conversations) => conversations,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchConversations());
  }
}
