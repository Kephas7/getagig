import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/presentation/view_model/organizer_gigs_viewmodel.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGigRepository extends Mock implements IGigRepository {}

class MockGetOrganizerProfileUseCase extends Mock
    implements GetOrganizerProfileUseCase {}

void main() {
  const tOrganizer = OrganizerEntity(
    id: 'organizer-profile-1',
    userId: 'user-1',
    organizationName: 'Event House',
    profilePicture: null,
    bio: null,
    contactPerson: 'Jane Doe',
    phone: '1234567890',
    email: 'events@example.com',
    location: 'Kathmandu, Nepal',
    organizationType: 'Events',
    eventTypes: ['Concert'],
    verificationDocuments: [],
    website: null,
    photos: [],
    videos: [],
    isVerified: true,
    verificationRequested: false,
    isActive: true,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  const tGigs = [
    GigEntity(
      id: 'gig-1',
      title: 'Rock Night',
      description: 'Live event',
      location: 'Kathmandu',
      genres: ['Rock'],
      instruments: ['Guitar'],
      payRate: 1200,
      eventType: 'Concert',
      status: 'open',
      organizerName: 'Event House',
      organizerId: 'organizer-profile-1',
    ),
  ];

  late MockGigRepository mockGigRepository;
  late MockGetOrganizerProfileUseCase mockGetOrganizerProfileUseCase;
  late ProviderContainer container;

  setUp(() {
    mockGigRepository = MockGigRepository();
    mockGetOrganizerProfileUseCase = MockGetOrganizerProfileUseCase();

    container = ProviderContainer(
      overrides: [
        gigRepositoryProvider.overrideWithValue(mockGigRepository),
        getOrganizerProfileUseCaseProvider.overrideWithValue(
          mockGetOrganizerProfileUseCase,
        ),
      ],
    );

    addTearDown(container.dispose);
  });

  test('loads only gigs for current organizer profile id', () async {
    when(
      () => mockGetOrganizerProfileUseCase(),
    ).thenAnswer((_) async => const Right(tOrganizer));
    when(
      () => mockGigRepository.getAllGigs(organizerId: tOrganizer.id),
    ).thenAnswer((_) async => const Right(tGigs));

    final result = await container.read(organizerGigsProvider.future);

    expect(result, tGigs);
    verify(() => mockGetOrganizerProfileUseCase()).called(1);
    verify(
      () => mockGigRepository.getAllGigs(organizerId: tOrganizer.id),
    ).called(1);
  });

  test('sets error state when organizer profile cannot be resolved', () async {
    const failure = ApiFailure(message: 'Organizer profile not found');
    when(
      () => mockGetOrganizerProfileUseCase(),
    ).thenAnswer((_) async => const Left(failure));

    container.read(organizerGigsProvider);

    for (var i = 0; i < 30; i++) {
      final state = container.read(organizerGigsProvider);
      if (state.hasError) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    final state = container.read(organizerGigsProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<ApiFailure>());

    verify(() => mockGetOrganizerProfileUseCase()).called(1);
    verifyNever(() => mockGigRepository.getAllGigs(organizerId: tOrganizer.id));
  });
}
