import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';
import 'package:getagig/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockApplicationRepository extends Mock
    implements IApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late GetMyApplicationsUseCase useCase;

  const tApplications = [
    ApplicationEntity(id: 'application-1', status: 'pending'),
  ];

  setUp(() {
    mockRepository = MockApplicationRepository();
    useCase = GetMyApplicationsUseCase(repository: mockRepository);
  });

  test('returns applications when repository succeeds', () async {
    when(
      () => mockRepository.getMyApplications(),
    ).thenAnswer((_) async => const Right(tApplications));

    final result = await useCase();

    expect(result, const Right(tApplications));
    verify(() => mockRepository.getMyApplications()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository getMyApplications fails', () async {
    const failure = ApiFailure(message: 'Failed to fetch applications');
    when(
      () => mockRepository.getMyApplications(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left(failure));
    verify(() => mockRepository.getMyApplications()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
