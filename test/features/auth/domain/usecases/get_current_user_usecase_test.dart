import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late GetCurrentUserUsecase useCase;

  const tUser = AuthEntity(
    username: 'testuser',
    email: 'test@example.com',
    role: 'musician',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUsecase(authRepository: mockRepository);
  });

  test('returns current user when repository succeeds', () async {
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await useCase();

    expect(result, const Right(tUser));
    verify(() => mockRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository getCurrentUser fails', () async {
    const failure = ApiFailure(message: 'User not authenticated');
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left(failure));
    verify(() => mockRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
