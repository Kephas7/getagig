import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUsecase useCase;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        username: 'fallback',
        email: 'fallback@example.com',
        role: 'musician',
      ),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUsecase(authRepository: mockRepository);
  });

  test('maps params to AuthEntity and returns success', () async {
    when(
      () => mockRepository.register(any()),
    ).thenAnswer((_) async => const Right(true));

    final result = await useCase(
      const RegisterParams(
        username: 'new-user',
        email: 'new@example.com',
        password: 'secret123',
        role: 'organizer',
      ),
    );

    expect(result, const Right(true));

    final captured =
        verify(() => mockRepository.register(captureAny())).captured.single
            as AuthEntity;
    expect(captured.username, 'new-user');
    expect(captured.email, 'new@example.com');
    expect(captured.password, 'secret123');
    expect(captured.role, 'organizer');
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository register fails', () async {
    const failure = ApiFailure(message: 'Email already registered');
    when(
      () => mockRepository.register(any()),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(
      const RegisterParams(
        username: 'new-user',
        email: 'new@example.com',
        password: 'secret123',
        role: 'organizer',
      ),
    );

    expect(result, const Left(failure));
    verify(() => mockRepository.register(any())).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
