import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';
import 'package:getagig/features/applications/domain/usecases/apply_to_gig_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockApplicationRepository extends Mock
    implements IApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late ApplyToGigUseCase useCase;

  const tApplication = ApplicationEntity(
    id: 'application-1',
    gigId: 'gig-1',
    musicianId: 'musician-1',
    status: 'pending',
    coverLetter: 'I am interested.',
  );

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = ApplyToGigUseCase(repository: mockRepository);
  });

  test('returns Right(null) when repository apply succeeds', () async {
    when(
      () => mockRepository.apply('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Right(tApplication));

    final result = await useCase('gig-1', 'Cover letter');

    expect(result, const Right(null));
    verify(() => mockRepository.apply('gig-1', 'Cover letter')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left(failure) when repository apply fails', () async {
    const failure = ApiFailure(message: 'Failed to apply');
    when(
      () => mockRepository.apply('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('gig-1', 'Cover letter');

    expect(result, const Left(failure));
    verify(() => mockRepository.apply('gig-1', 'Cover letter')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
