import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockApiClient mockApiClient;
  late MockUserSessionService mockUserSessionService;
  late AuthRemoteDatasource datasource;

  const testUser = AuthApiModel(
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123',
    role: 'musician',
  );

  setUp(() {
    mockApiClient = MockApiClient();
    mockUserSessionService = MockUserSessionService();
    datasource = AuthRemoteDatasource(
      apiClient: mockApiClient,
      userSessionService: mockUserSessionService,
    );
  });

  group('register', () {
    test('sends confirmPassword and returns parsed user on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.register),
        data: {
          'success': true,
          'data': {
            '_id': 'user-1',
            'username': 'testuser',
            'email': 'test@example.com',
            'role': 'musician',
          },
        },
        statusCode: 201,
      );

      when(
        () =>
            mockApiClient.post(ApiEndpoints.register, data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await datasource.register(testUser);

      expect(result.id, 'user-1');
      expect(result.email, 'test@example.com');
      final verification = verify(
        () => mockApiClient.post(
          ApiEndpoints.register,
          data: captureAny(named: 'data'),
        ),
      );
      verification.called(1);

      final capturedPayload =
          verification.captured.single as Map<String, dynamic>;

      expect(capturedPayload['confirmPassword'], 'password123');
    });

    test(
      'throws first validation error message when success is false',
      () async {
        final response = Response(
          requestOptions: RequestOptions(path: ApiEndpoints.register),
          data: {
            'success': false,
            'message': 'Validation Error',
            'errors': [
              {
                'path': 'confirmPassword',
                'message': 'Confirm password is required',
              },
            ],
          },
          statusCode: 400,
        );

        when(
          () => mockApiClient.post(
            ApiEndpoints.register,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => response);

        expect(
          () => datasource.register(testUser),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Confirm password is required'),
            ),
          ),
        );
      },
    );

    test(
      'throws API message when success is false and no field errors',
      () async {
        final response = Response(
          requestOptions: RequestOptions(path: ApiEndpoints.register),
          data: {'success': false, 'message': 'Email already registered.'},
          statusCode: 403,
        );

        when(
          () => mockApiClient.post(
            ApiEndpoints.register,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => response);

        expect(
          () => datasource.register(testUser),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Email already registered.'),
            ),
          ),
        );
      },
    );
  });
}
