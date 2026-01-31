import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/features/musician/domain/usecases/update_availability_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockMusicianRepository extends Mock implements IMusicianRepository {}

void main() {
  late UpdateAvailabilityUseCase usecase;
  late MockMusicianRepository mockRepository;

  setUp(() {
    mockRepository = MockMusicianRepository();
    usecase = UpdateAvailabilityUseCase(repository: mockRepository);
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
    isAvailable: false,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  test(
    'should return updated musician entity when update is successful',
    () async {
      when(
        () => mockRepository.updateAvailability(true),
      ).thenAnswer((_) async => const Right(tMusician));

      final result = await usecase(
        const UpdateAvailabilityParams(isAvailable: true),
      );

      expect(result, const Right(tMusician));
      verify(() => mockRepository.updateAvailability(true)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return failure when update fails', () async {
    const failure = ApiFailure(message: 'Update failed');
    when(
      () => mockRepository.updateAvailability(false),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(
      const UpdateAvailabilityParams(isAvailable: false),
    );

    expect(result, const Left(failure));
    verify(() => mockRepository.updateAvailability(false)).called(1);
  });
}
