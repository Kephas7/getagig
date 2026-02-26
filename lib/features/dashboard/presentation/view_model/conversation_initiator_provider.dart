import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/dashboard/data/models/conversation_model.dart';
import 'package:getagig/features/dashboard/data/repositories/message_repository.dart';

/// Provider for initiating new conversations with users
final conversationInitiatorProvider =
    StateNotifierProvider<ConversationInitiatorNotifier, AsyncValue<void>>((
      ref,
    ) {
      return ConversationInitiatorNotifier(ref);
    });

class ConversationInitiatorNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ConversationInitiatorNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Start a new conversation with a specific user
  /// Returns the conversation model if created or found
  Future<Either<Failure, ConversationModel>> startConversation(
    String recipientId,
  ) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(messageRepositoryProvider);

      // Call backend to create or get existing conversation
      final result = await repo.startConversation(recipientId: recipientId);

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (conversation) {
          state = const AsyncValue.data(null);
        },
      );

      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
