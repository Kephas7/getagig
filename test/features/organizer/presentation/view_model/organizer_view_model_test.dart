import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizerRepository extends Mock implements IOrganizerRepository {}

void main() {
  late ProviderContainer container;
  late MockOrganizerRepository mockRepository;

  const tProfile = OrganizerEntity(
    id: 'organizer-1',
    userId: 'user-1',
    organizationName: 'Event House',
    profilePicture: null,
    bio: 'We produce live events',
    contactPerson: 'Jane Doe',
    phone: '9800000002',
    email: 'events@example.com',
    location: 'Kathmandu',
    organizationType: 'Events',
    eventTypes: ['Concert'],
    verificationDocuments: [],
    website: null,
    photos: [],
    videos: [],
    isVerified: false,
    verificationRequested: false,
    isActive: true,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-02',
  );

  setUp(() {
    mockRepository = MockOrganizerRepository();

    container = ProviderContainer(
      overrides: [
        organizerRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    addTearDown(container.dispose);
  });

  test('getProfile sets loaded state when profile is fetched', () async {
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Right(tProfile));

    final notifier = container.read(organizerProfileViewModelProvider.notifier);
    await notifier.getProfile();

    final state = container.read(organizerProfileViewModelProvider);
    expect(state.status, OrganizerProfileStatus.loaded);
    expect(state.profile, tProfile);
    expect(state.errorMessage, isNull);
    verify(() => mockRepository.getProfile()).called(1);
  });

  test('getProfile resets to initial when profile is not found', () async {
    const failure = ApiFailure(message: 'Profile not found');
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(organizerProfileViewModelProvider.notifier);
    await notifier.getProfile();

    final state = container.read(organizerProfileViewModelProvider);
    expect(state.status, OrganizerProfileStatus.initial);
    expect(state.profile, isNull);
    expect(state.errorMessage, isNull);
    verify(() => mockRepository.getProfile()).called(1);
  });
}
