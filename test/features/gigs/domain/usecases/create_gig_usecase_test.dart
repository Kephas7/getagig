import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/usecases/create_gig_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

void main() {
  late MockGigRepository mockRepository;
  late CreateGigUseCase useCase;

  const tGig = GigEntity(
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
  );

  final tData = <String, dynamic>{
    'title': 'Rock Night',
    'description': 'Live rock performance',
  };

  setUp(() {
    mockRepository = MockGigRepository();
    useCase = CreateGigUseCase(repository: mockRepository);
  });

  test('returns created gig when repository createGig succeeds', () async {
    when(
      () => mockRepository.createGig(tData),
    ).thenAnswer((_) async => const Right(tGig));

    final result = await useCase(tData);

    expect(result, const Right(tGig));
    verify(() => mockRepository.createGig(tData)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository createGig fails', () async {
    const failure = ApiFailure(message: 'Failed to create gig');
    when(
      () => mockRepository.createGig(tData),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(tData);

    expect(result, const Left(failure));
    verify(() => mockRepository.createGig(tData)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
