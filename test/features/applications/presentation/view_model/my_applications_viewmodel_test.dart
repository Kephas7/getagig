import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/usecases/apply_to_gig_usecase.dart';
import 'package:getagig/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:getagig/features/applications/presentation/view_model/my_applications_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyApplicationsUseCase extends Mock
    implements GetMyApplicationsUseCase {}

class MockApplyToGigUseCase extends Mock implements ApplyToGigUseCase {}

void main() {
  late ProviderContainer container;
  late MockGetMyApplicationsUseCase mockGetMyApplicationsUseCase;
  late MockApplyToGigUseCase mockApplyToGigUseCase;

  const initialApplications = [
    ApplicationEntity(id: 'application-1', status: 'pending'),
  ];

  const refreshedApplications = [
    ApplicationEntity(id: 'application-2', status: 'accepted'),
  ];

  setUp(() {
    mockGetMyApplicationsUseCase = MockGetMyApplicationsUseCase();
    mockApplyToGigUseCase = MockApplyToGigUseCase();

    container = ProviderContainer(
      overrides: [
        getMyApplicationsUseCaseProvider.overrideWithValue(
          mockGetMyApplicationsUseCase,
        ),
        applyToGigUseCaseProvider.overrideWithValue(mockApplyToGigUseCase),
      ],
    );

    addTearDown(container.dispose);
  });

  test('build loads applications from getMyApplications usecase', () async {
    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => const Right(initialApplications));

    final result = await container.read(myApplicationsProvider.future);

    expect(result, initialApplications);
    verify(() => mockGetMyApplicationsUseCase()).called(1);
  });

  test('apply refreshes applications on success', () async {
    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => const Right(initialApplications));
    await container.read(myApplicationsProvider.future);

    when(
      () => mockApplyToGigUseCase('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => const Right(refreshedApplications));

    await container
        .read(myApplicationsProvider.notifier)
        .apply('gig-1', 'Cover letter');

    final state = container.read(myApplicationsProvider);
    expect(state.value, refreshedApplications);
    verify(() => mockApplyToGigUseCase('gig-1', 'Cover letter')).called(1);
    verify(() => mockGetMyApplicationsUseCase()).called(2);
  });

  test('apply throws and does not refresh when apply usecase fails', () async {
    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => const Right(initialApplications));
    await container.read(myApplicationsProvider.future);

    const failure = ApiFailure(message: 'Failed to apply');
    when(
      () => mockApplyToGigUseCase('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Left(failure));

    await expectLater(
      container
          .read(myApplicationsProvider.notifier)
          .apply('gig-1', 'Cover letter'),
      throwsA(equals('Failed to apply')),
    );

    final state = container.read(myApplicationsProvider);
    expect(state.value, initialApplications);
    verify(() => mockApplyToGigUseCase('gig-1', 'Cover letter')).called(1);
    verify(() => mockGetMyApplicationsUseCase()).called(1);
  });
}
