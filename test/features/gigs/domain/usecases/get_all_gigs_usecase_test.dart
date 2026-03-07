import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/usecases/get_all_gigs_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

void main() {
  late MockGigRepository mockRepository;
  late GetAllGigsUseCase useCase;

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
    mockRepository = MockGigRepository();
    useCase = GetAllGigsUseCase(repository: mockRepository);
  });

  test('returns gigs filtered by organizer when repository succeeds', () async {
    when(
      () => mockRepository.getAllGigs(organizerId: 'organizer-1'),
    ).thenAnswer((_) async => const Right(tGigs));

    final result = await useCase(organizerId: 'organizer-1');

    expect(result, const Right(tGigs));
    verify(
      () => mockRepository.getAllGigs(organizerId: 'organizer-1'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository getAllGigs fails', () async {
    const failure = ApiFailure(message: 'Failed to fetch gigs');
    when(
      () => mockRepository.getAllGigs(organizerId: 'organizer-1'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(organizerId: 'organizer-1');

    expect(result, const Left(failure));
    verify(
      () => mockRepository.getAllGigs(organizerId: 'organizer-1'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
