import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/features/musician/domain/usecases/get_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockMusicianRepository extends Mock implements IMusicianRepository {}

void main() {
  late GetProfileUseCase usecase;
  late MockMusicianRepository mockRepository;

  setUp(() {
    mockRepository = MockMusicianRepository();
    usecase = GetProfileUseCase(repository: mockRepository);
  });

  const tMusician = MusicianEntity(
    id: 'id1',
    userId: 'user1',
    stageName: 'Stage One',
    profilePicture: null,
    bio: 'Bio',
    phone: '1234567890',
    location: {'city': 'Kathmandu', 'country': 'Nepal'},
    genres: ['Rock'],
    instruments: ['Guitar'],
    experienceYears: 3,
    hourlyRate: 50.0,
    photos: ['p1'],
    videos: ['v1'],
    audioSamples: ['a1'],
    isAvailable: true,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  test(
    'should return musician entity when repository call is successful',
    () async {
      when(
        () => mockRepository.getProfile(),
      ).thenAnswer((_) async => const Right(tMusician));

      final result = await usecase();

      expect(result, const Right(tMusician));
      verify(() => mockRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return failure when repository fails', () async {
    const failure = ApiFailure(message: 'Server error');
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase();

    expect(result, const Left(failure));
    verify(() => mockRepository.getProfile()).called(1);
  });
}
