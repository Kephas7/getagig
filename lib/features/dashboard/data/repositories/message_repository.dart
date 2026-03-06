import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/dashboard/data/models/conversation_model.dart';
import 'package:getagig/features/dashboard/data/models/message_model.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(
    apiClient: ref.read(apiClientProvider),
    hiveService: ref.read(hiveServiceProvider),
  );
});

class MessageRepository {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  MessageRepository({
    required ApiClient apiClient,
    required HiveService hiveService,
  }) : _apiClient = apiClient,
       _hiveService = hiveService;

  Future<Either<Failure, List<ConversationModel>>> getConversations() async {
    final cached = _hiveService.getConversations();

    try {
      final response = await _apiClient.get(ApiEndpoints.conversations);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final conversations = data
            .map(
              (e) => ConversationModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        await _hiveService.saveConversations(conversations);
        return Right(conversations);
      }
      return cached.isNotEmpty
          ? Right(cached)
          : const Left(ApiFailure(message: 'Failed to fetch conversations'));
    } catch (e) {
      if (cached.isNotEmpty) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<MessageModel>>> getMessages(
    String conversationId,
  ) async {
    final cached = _hiveService.getMessages(conversationId);

    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversationMessages(conversationId),
      );

      if (response.data['success'] == true) {
        final dynamic payload = response.data['data'];
        final List<dynamic> data = payload is Map<String, dynamic>
            ? (payload['messages'] as List<dynamic>? ?? [])
            : (payload as List<dynamic>? ?? []);

        final messages = data
            .map(
              (e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();

        await _hiveService.saveMessages(messages);
        return Right(messages);
      }
      return cached.isNotEmpty
          ? Right(cached)
          : const Left(ApiFailure(message: 'Failed to fetch messages'));
    } catch (e) {
      if (cached.isNotEmpty) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, MessageModel>> sendMessage({
    required String content,
    String? conversationId,
    String? receiverId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendMessage,
        data: {
          'content': content,
          'conversationId': conversationId,
          'receiverId': receiverId,
        },
      );
      if (response.data['success'] == true) {
        final message = MessageModel.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
        await _hiveService.saveMessages([message]);
        return Right(message);
      }
      return const Left(ApiFailure(message: 'Failed to send message'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ConversationModel>> startConversation({
    required String recipientId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.startConversation,
        data: {'recipientId': recipientId},
      );
      if (response.data['success'] == true) {
        final conversation = ConversationModel.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
        await _hiveService.saveConversations([conversation]);
        return Right(conversation);
      }
      return const Left(ApiFailure(message: 'Failed to start conversation'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> clearConversation({
    required String conversationId,
  }) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.clearConversationMessages(conversationId),
      );

      if (response.data['success'] == true) {
        await _hiveService.clearMessagesForConversation(conversationId);
        await _hiveService.updateConversationPreview(
          conversationId: conversationId,
          lastMessage: null,
        );
        return const Right(true);
      }

      final message =
          response.data['message']?.toString() ??
          'Failed to clear conversation';
      return Left(ApiFailure(message: message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteConversation({
    required String conversationId,
  }) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.deleteConversation(conversationId),
      );

      if (response.data['success'] == true) {
        await _hiveService.clearMessagesForConversation(conversationId);
        await _hiveService.deleteConversation(conversationId);
        return const Right(true);
      }

      final message =
          response.data['message']?.toString() ??
          'Failed to delete conversation';
      return Left(ApiFailure(message: message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
