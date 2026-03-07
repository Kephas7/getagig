import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';
import 'package:getagig/features/applications/domain/usecases/get_gig_applications_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockApplicationRepository extends Mock
    implements IApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late GetGigApplicationsUseCase useCase;

  const tApplications = [
    ApplicationEntity(id: 'application-1', gigId: 'gig-1', status: 'pending'),
  ];

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = GetGigApplicationsUseCase(repository: mockRepository);
  });

  test('returns gig applications when repository succeeds', () async {
    when(
      () => mockRepository.getGigApplications('gig-1'),
    ).thenAnswer((_) async => const Right(tApplications));

    final result = await useCase('gig-1');

    expect(result, const Right(tApplications));
    verify(() => mockRepository.getGigApplications('gig-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository getGigApplications fails', () async {
    const failure = ApiFailure(message: 'Failed to fetch gig applications');
    when(
      () => mockRepository.getGigApplications('gig-1'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('gig-1');

    expect(result, const Left(failure));
    verify(() => mockRepository.getGigApplications('gig-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
