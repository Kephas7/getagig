import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/usecases/update_gig_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

void main() {
  late MockGigRepository mockRepository;
  late UpdateGigUseCase useCase;

  const tUpdatedGig = GigEntity(
    id: 'gig-1',
    title: 'Rock Night Reloaded',
    description: 'Updated details',
    location: 'Kathmandu',
    genres: ['Rock'],
    instruments: ['Guitar'],
    payRate: 1500,
    eventType: 'Concert',
    status: 'open',
    organizerName: 'Event House',
    organizerId: 'organizer-1',
  );

  final tUpdates = <String, dynamic>{
    'title': 'Rock Night Reloaded',
    'payRate': 1500,
  };

  setUp(() {
    mockRepository = MockGigRepository();
    useCase = UpdateGigUseCase(repository: mockRepository);
  });

  test('returns updated gig when repository updateGig succeeds', () async {
    when(
      () => mockRepository.updateGig('gig-1', tUpdates),
    ).thenAnswer((_) async => const Right(tUpdatedGig));

    final result = await useCase('gig-1', tUpdates);

    expect(result, const Right(tUpdatedGig));
    verify(() => mockRepository.updateGig('gig-1', tUpdates)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository updateGig fails', () async {
    const failure = ApiFailure(message: 'Failed to update gig');
    when(
      () => mockRepository.updateGig('gig-1', tUpdates),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('gig-1', tUpdates);

    expect(result, const Left(failure));
    verify(() => mockRepository.updateGig('gig-1', tUpdates)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
