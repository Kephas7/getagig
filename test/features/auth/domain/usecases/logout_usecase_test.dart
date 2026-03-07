import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUsecase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUsecase(authRepository: mockRepository);
  });

  test('returns true when repository logout succeeds', () async {
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Right(true));

    final result = await useCase();

    expect(result, const Right(true));
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository logout fails', () async {
    const failure = LocalDatabaseFailure(message: 'Logout failed');
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left(failure));
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
