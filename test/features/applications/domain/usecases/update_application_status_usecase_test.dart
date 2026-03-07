import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';
import 'package:getagig/features/applications/domain/usecases/update_application_status_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockApplicationRepository extends Mock
    implements IApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late UpdateApplicationStatusUseCase useCase;

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = UpdateApplicationStatusUseCase(repository: mockRepository);
  });

  test('returns true when repository updateStatus succeeds', () async {
    when(
      () => mockRepository.updateStatus('application-1', 'accepted'),
    ).thenAnswer((_) async => const Right(true));

    final result = await useCase('application-1', 'accepted');

    expect(result, const Right(true));
    verify(
      () => mockRepository.updateStatus('application-1', 'accepted'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository updateStatus fails', () async {
    const failure = ApiFailure(message: 'Failed to update application status');
    when(
      () => mockRepository.updateStatus('application-1', 'accepted'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('application-1', 'accepted');

    expect(result, const Left(failure));
    verify(
      () => mockRepository.updateStatus('application-1', 'accepted'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
