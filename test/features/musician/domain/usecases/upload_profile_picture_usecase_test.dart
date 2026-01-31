import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/features/musician/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockMusicianRepository extends Mock implements IMusicianRepository {}

class FakeFile extends Fake implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  late UploadProfilePictureUseCase usecase;
  late MockMusicianRepository mockRepository;

  setUp(() {
    mockRepository = MockMusicianRepository();
    usecase = UploadProfilePictureUseCase(repository: mockRepository);
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

  test('should return updated musician entity when upload succeeds', () async {
    
    final file = File('test_resources/dummy.jpg');
    when(
      () => mockRepository.uploadProfilePicture(any()),
    ).thenAnswer((_) async => const Right(tMusician));

    
    final result = await usecase(file);

    
    expect(result, const Right(tMusician));
    verify(() => mockRepository.uploadProfilePicture(any())).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when upload fails', () async {
    
    final file = File('test_resources/dummy.jpg');
    const failure = ApiFailure(message: 'Upload failed');
    when(
      () => mockRepository.uploadProfilePicture(any()),
    ).thenAnswer((_) async => const Left(failure));

    
    final result = await usecase(file);

    
    expect(result, const Left(failure));
    verify(() => mockRepository.uploadProfilePicture(any())).called(1);
  });
}
