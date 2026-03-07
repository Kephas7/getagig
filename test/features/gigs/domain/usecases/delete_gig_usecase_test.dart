import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/usecases/delete_gig_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

void main() {
  late MockGigRepository mockRepository;
  late DeleteGigUseCase useCase;

  setUp(() {
    mockRepository = MockGigRepository();
    useCase = DeleteGigUseCase(repository: mockRepository);
  });

  test('returns Right(null) when repository deleteGig succeeds', () async {
    when(
      () => mockRepository.deleteGig('gig-1'),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase('gig-1');

    expect(result, const Right(null));
    verify(() => mockRepository.deleteGig('gig-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository deleteGig fails', () async {
    const failure = ApiFailure(message: 'Failed to delete gig');
    when(
      () => mockRepository.deleteGig('gig-1'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('gig-1');

    expect(result, const Left(failure));
    verify(() => mockRepository.deleteGig('gig-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
