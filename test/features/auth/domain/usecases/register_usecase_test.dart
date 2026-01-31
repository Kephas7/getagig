import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });
  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(username: 'fallback', email: 'fallback@email.com'),
    );
  });

  const tUsername = 'testuser';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tRole = 'musician';

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        const RegisterParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
    test('should pass AuthEntity with correct values to repository', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(
        const RegisterParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.role, tRole);
    });
    test('should return failure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure();
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });
    group('RegisterParams', () {
      test('should have correct props with all values', () {
        // Arrange
        const params = RegisterParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          role: tRole,
        );

        // Assert
        expect(params.props, [tUsername, tEmail, tPassword, tRole]);
      });
      test('two params with same values should be equal', () {
        // Arrange
        const params1 = RegisterParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          role: tRole,
        );
        const params2 = RegisterParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          role: tRole,
        );

        // Assert
        expect(params1, params2);
      });
    });
  });
}
