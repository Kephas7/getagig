import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase useCase;

  const tUser = AuthEntity(
    username: 'testuser',
    email: 'test@example.com',
    role: 'musician',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUsecase(authRepository: mockRepository);
  });

  test('returns authenticated user when repository login succeeds', () async {
    when(
      () => mockRepository.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await useCase(
      const LoginParams(email: 'test@example.com', password: 'password123'),
    );

    expect(result, const Right(tUser));
    verify(
      () => mockRepository.login('test@example.com', 'password123'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository login fails', () async {
    const failure = ApiFailure(message: 'Invalid credentials');
    when(
      () => mockRepository.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(
      const LoginParams(email: 'test@example.com', password: 'password123'),
    );

    expect(result, const Left(failure));
    verify(
      () => mockRepository.login('test@example.com', 'password123'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
