import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/usecases/apply_to_gig_usecase.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/usecases/get_all_gigs_usecase.dart';
import 'package:getagig/features/gigs/presentation/state/gigs_state.dart';
import 'package:getagig/features/gigs/presentation/view_model/gigs_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllGigsUseCase extends Mock implements GetAllGigsUseCase {}

class MockApplyToGigUseCase extends Mock implements ApplyToGigUseCase {}

void main() {
  late ProviderContainer container;
  late MockGetAllGigsUseCase mockGetAllGigsUseCase;
  late MockApplyToGigUseCase mockApplyToGigUseCase;

  const tGigs = [
    GigEntity(
      id: 'gig-1',
      title: 'Rock Night',
      description: 'Live rock performance',
      location: 'Kathmandu',
      genres: ['Rock'],
      instruments: ['Guitar'],
      payRate: 1200,
      eventType: 'Concert',
      status: 'open',
      organizerName: 'Event House',
      organizerId: 'organizer-1',
    ),
  ];

  setUp(() {
    mockGetAllGigsUseCase = MockGetAllGigsUseCase();
    mockApplyToGigUseCase = MockApplyToGigUseCase();

    container = ProviderContainer(
      overrides: [
        getAllGigsUseCaseProvider.overrideWithValue(mockGetAllGigsUseCase),
        applyToGigUseCaseProvider.overrideWithValue(mockApplyToGigUseCase),
      ],
    );

    addTearDown(container.dispose);
  });

  test('getAllGigs sets loaded state when usecase succeeds', () async {
    when(
      () => mockGetAllGigsUseCase(),
    ).thenAnswer((_) async => const Right(tGigs));

    final notifier = container.read(gigsViewModelProvider.notifier);
    await notifier.getAllGigs();

    final state = container.read(gigsViewModelProvider);
    expect(state.status, GigsStatus.loaded);
    expect(state.gigs, tGigs);
    expect(state.errorMessage, isNull);
    verify(() => mockGetAllGigsUseCase()).called(1);
  });

  test('getAllGigs sets error state when usecase fails', () async {
    const failure = ApiFailure(message: 'Failed to load gigs');
    when(
      () => mockGetAllGigsUseCase(),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(gigsViewModelProvider.notifier);
    await notifier.getAllGigs();

    final state = container.read(gigsViewModelProvider);
    expect(state.status, GigsStatus.error);
    expect(state.errorMessage, 'Failed to load gigs');
    verify(() => mockGetAllGigsUseCase()).called(1);
  });

  test('applyToGig sets applied state when usecase succeeds', () async {
    when(
      () => mockApplyToGigUseCase('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Right(null));

    final notifier = container.read(gigsViewModelProvider.notifier);
    await notifier.applyToGig('gig-1', 'Cover letter');

    final state = container.read(gigsViewModelProvider);
    expect(state.status, GigsStatus.applied);
    expect(state.errorMessage, isNull);
    verify(() => mockApplyToGigUseCase('gig-1', 'Cover letter')).called(1);
  });

  test('applyToGig sets error state when usecase fails', () async {
    const failure = ApiFailure(message: 'Already applied');
    when(
      () => mockApplyToGigUseCase('gig-1', 'Cover letter'),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(gigsViewModelProvider.notifier);
    await notifier.applyToGig('gig-1', 'Cover letter');

    final state = container.read(gigsViewModelProvider);
    expect(state.status, GigsStatus.error);
    expect(state.errorMessage, 'Already applied');
    verify(() => mockApplyToGigUseCase('gig-1', 'Cover letter')).called(1);
  });
}
