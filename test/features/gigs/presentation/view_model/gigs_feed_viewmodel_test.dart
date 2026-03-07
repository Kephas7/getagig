import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/presentation/view_model/gigs_feed_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

void main() {
  late ProviderContainer container;
  late MockGigRepository mockRepository;

  const initialGigs = [
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

  const refreshedGigs = [
    GigEntity(
      id: 'gig-2',
      title: 'Jazz Evening',
      description: 'Smooth jazz set',
      location: 'Pokhara',
      genres: ['Jazz'],
      instruments: ['Saxophone'],
      payRate: 1500,
      eventType: 'Live',
      status: 'open',
      organizerName: 'Blue Note',
      organizerId: 'organizer-2',
    ),
  ];

  setUp(() {
    mockRepository = MockGigRepository();

    container = ProviderContainer(
      overrides: [gigRepositoryProvider.overrideWithValue(mockRepository)],
    );

    addTearDown(container.dispose);
  });

  test('build loads gigs from repository', () async {
    when(
      () => mockRepository.getAllGigs(organizerId: null),
    ).thenAnswer((_) async => const Right(initialGigs));

    final result = await container.read(gigsFeedProvider.future);

    expect(result, initialGigs);
    verify(() => mockRepository.getAllGigs(organizerId: null)).called(1);
  });

  test('refresh updates state with latest gigs', () async {
    when(
      () => mockRepository.getAllGigs(organizerId: null),
    ).thenAnswer((_) async => const Right(initialGigs));
    await container.read(gigsFeedProvider.future);

    when(
      () => mockRepository.getAllGigs(organizerId: null),
    ).thenAnswer((_) async => const Right(refreshedGigs));

    await container.read(gigsFeedProvider.notifier).refresh();

    final state = container.read(gigsFeedProvider);
    expect(state.value, refreshedGigs);
    verify(() => mockRepository.getAllGigs(organizerId: null)).called(2);
  });
}
