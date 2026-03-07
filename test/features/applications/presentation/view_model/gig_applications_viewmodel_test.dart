import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/usecases/get_gig_applications_usecase.dart';
import 'package:getagig/features/applications/presentation/view_model/gig_applications_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGetGigApplicationsUseCase extends Mock
    implements GetGigApplicationsUseCase {}

void main() {
  late ProviderContainer container;
  late MockGetGigApplicationsUseCase mockGetGigApplicationsUseCase;

  const tApplications = [
    ApplicationEntity(id: 'application-1', gigId: 'gig-1', status: 'pending'),
  ];

  setUp(() {
    mockGetGigApplicationsUseCase = MockGetGigApplicationsUseCase();

    container = ProviderContainer(
      overrides: [
        getGigApplicationsUseCaseProvider.overrideWithValue(
          mockGetGigApplicationsUseCase,
        ),
      ],
    );

    addTearDown(container.dispose);
  });

  test('loads gig applications when usecase succeeds', () async {
    when(
      () => mockGetGigApplicationsUseCase('gig-1'),
    ).thenAnswer((_) async => const Right(tApplications));

    final result = await container.read(
      gigApplicationsProvider('gig-1').future,
    );

    expect(result, tApplications);
    verify(() => mockGetGigApplicationsUseCase('gig-1')).called(1);
  });

  test('throws message when usecase fails', () async {
    const failure = ApiFailure(message: 'Failed to fetch gig applications');
    when(
      () => mockGetGigApplicationsUseCase('gig-1'),
    ).thenAnswer((_) async => const Left(failure));

    final provider = gigApplicationsProvider('gig-1');
    final done = Completer<void>();

    final subscription = container.listen<AsyncValue<List<ApplicationEntity>>>(
      provider,
      (_, next) {
        if (next.hasError && !done.isCompleted) {
          done.complete();
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await done.future.timeout(const Duration(seconds: 2));

    final state = container.read(provider);
    expect(state.hasError, isTrue);
    expect(state.error, 'Failed to fetch gig applications');
    verify(() => mockGetGigApplicationsUseCase('gig-1')).called(1);
  });
}
