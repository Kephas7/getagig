import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
  })  : _apiClient = apiClient,
        _hiveService = hiveService;

  Future<Either<Failure, List<ConversationModel>>> getConversations() async {
    final cached = _hiveService.getConversations();

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.baseUrl}/messages/conversations',
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final conversations =
            data.map((e) => ConversationModel.fromJson(e)).toList();

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
        '${ApiEndpoints.baseUrl}/messages/conversations/$conversationId',
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final messages = data.map((e) => MessageModel.fromJson(e)).toList();

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
        '${ApiEndpoints.baseUrl}/messages/send',
        data: {
          'content': content,
          'conversationId': conversationId,
          'receiverId': receiverId,
        },
      );
      if (response.data['success'] == true) {
        final message = MessageModel.fromJson(response.data['data']);
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
        '${ApiEndpoints.baseUrl}/messages/conversations/start',
        data: {'recipientId': recipientId},
      );
      if (response.data['success'] == true) {
        final conversation = ConversationModel.fromJson(response.data['data']);
        await _hiveService.saveConversations([conversation]);
        return Right(conversation);
      }
      return const Left(ApiFailure(message: 'Failed to start conversation'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
