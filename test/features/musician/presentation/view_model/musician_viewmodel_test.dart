import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/musician/data/musician_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockMusicianRepository extends Mock implements IMusicianRepository {}

void main() {
  late ProviderContainer container;
  late MockMusicianRepository mockRepository;

  const tProfile = MusicianEntity(
    id: 'musician-1',
    userId: 'user-1',
    stageName: 'Stage One',
    profilePicture: null,
    bio: 'Session guitarist',
    phone: '9800000001',
    location: 'Kathmandu',
    genres: ['Rock'],
    instruments: ['Guitar'],
    experienceYears: 5,
    hourlyRate: 3000,
    photos: [],
    videos: [],
    audioSamples: [],
    isVerified: false,
    verificationRequested: false,
    isAvailable: true,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-02',
  );

  setUp(() {
    mockRepository = MockMusicianRepository();

    container = ProviderContainer(
      overrides: [musicianRepositoryProvider.overrideWithValue(mockRepository)],
    );

    addTearDown(container.dispose);
  });

  test('getProfile sets loaded state when profile is fetched', () async {
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Right(tProfile));

    final notifier = container.read(musicianProfileViewModelProvider.notifier);
    await notifier.getProfile();

    final state = container.read(musicianProfileViewModelProvider);
    expect(state.status, MusicianProfileStatus.loaded);
    expect(state.profile, tProfile);
    expect(state.errorMessage, isNull);
    verify(() => mockRepository.getProfile()).called(1);
  });

  test('getProfile resets to initial when profile is not found', () async {
    const failure = ApiFailure(message: 'Profile not found');
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(musicianProfileViewModelProvider.notifier);
    await notifier.getProfile();

    final state = container.read(musicianProfileViewModelProvider);
    expect(state.status, MusicianProfileStatus.initial);
    expect(state.profile, isNull);
    expect(state.errorMessage, isNull);
    verify(() => mockRepository.getProfile()).called(1);
  });
}
