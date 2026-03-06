import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/dashboard/data/repositories/message_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockApiClient mockApiClient;
  late MockHiveService mockHiveService;
  late MessageRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockHiveService = MockHiveService();
    repository = MessageRepository(
      apiClient: mockApiClient,
      hiveService: mockHiveService,
    );
  });

  group('clearConversation', () {
    test('returns Right(true) and updates local cache on success', () async {
      const conversationId = 'conv-1';

      when(
        () => mockApiClient.delete(
          ApiEndpoints.clearConversationMessages(conversationId),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.clearConversationMessages(conversationId),
          ),
          data: {'success': true},
          statusCode: 200,
        ),
      );

      when(
        () => mockHiveService.clearMessagesForConversation(conversationId),
      ).thenAnswer((_) async {});
      when(
        () => mockHiveService.updateConversationPreview(
          conversationId: conversationId,
          lastMessage: null,
        ),
      ).thenAnswer((_) async {});

      final result = await repository.clearConversation(
        conversationId: conversationId,
      );

      result.fold(
        (failure) => fail('Expected success, got failure: ${failure.message}'),
        (success) => expect(success, isTrue),
      );

      verify(
        () => mockApiClient.delete(
          ApiEndpoints.clearConversationMessages(conversationId),
        ),
      ).called(1);
      verify(
        () => mockHiveService.clearMessagesForConversation(conversationId),
      ).called(1);
      verify(
        () => mockHiveService.updateConversationPreview(
          conversationId: conversationId,
          lastMessage: null,
        ),
      ).called(1);
    });

    test('returns Left(ApiFailure) when API reports failure', () async {
      const conversationId = 'conv-1';

      when(
        () => mockApiClient.delete(
          ApiEndpoints.clearConversationMessages(conversationId),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.clearConversationMessages(conversationId),
          ),
          data: {'success': false, 'message': 'Not authorized'},
          statusCode: 403,
        ),
      );

      final result = await repository.clearConversation(
        conversationId: conversationId,
      );

      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect(failure.message, 'Not authorized');
      }, (_) => fail('Expected failure but got success'));

      verifyNever(
        () => mockHiveService.clearMessagesForConversation(any<String>()),
      );
    });
  });

  group('deleteConversation', () {
    test('returns Right(true) and removes local cache on success', () async {
      const conversationId = 'conv-1';

      when(
        () => mockApiClient.delete(
          ApiEndpoints.deleteConversation(conversationId),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.deleteConversation(conversationId),
          ),
          data: {'success': true},
          statusCode: 200,
        ),
      );

      when(
        () => mockHiveService.clearMessagesForConversation(conversationId),
      ).thenAnswer((_) async {});
      when(
        () => mockHiveService.deleteConversation(conversationId),
      ).thenAnswer((_) async {});

      final result = await repository.deleteConversation(
        conversationId: conversationId,
      );

      result.fold(
        (failure) => fail('Expected success, got failure: ${failure.message}'),
        (success) => expect(success, isTrue),
      );

      verify(
        () => mockApiClient.delete(
          ApiEndpoints.deleteConversation(conversationId),
        ),
      ).called(1);
      verify(
        () => mockHiveService.clearMessagesForConversation(conversationId),
      ).called(1);
      verify(
        () => mockHiveService.deleteConversation(conversationId),
      ).called(1);
    });

    test('returns Left(ApiFailure) when delete request throws', () async {
      const conversationId = 'conv-1';

      when(
        () => mockApiClient.delete(
          ApiEndpoints.deleteConversation(conversationId),
        ),
      ).thenThrow(Exception('network error'));

      final result = await repository.deleteConversation(
        conversationId: conversationId,
      );

      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect(failure.message, contains('network error'));
      }, (_) => fail('Expected failure but got success'));
    });
  });
}
