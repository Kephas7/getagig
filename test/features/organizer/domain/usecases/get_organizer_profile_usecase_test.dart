import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizerRepository extends Mock implements IOrganizerRepository {}

void main() {
  late MockOrganizerRepository mockRepository;
  late GetOrganizerProfileUseCase useCase;

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
    useCase = GetOrganizerProfileUseCase(repository: mockRepository);
  });

  test('returns organizer profile when repository succeeds', () async {
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Right(tProfile));

    final result = await useCase();

    expect(result, const Right(tProfile));
    verify(() => mockRepository.getProfile()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository getProfile fails', () async {
    const failure = ApiFailure(message: 'Unable to load organizer profile');
    when(
      () => mockRepository.getProfile(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left(failure));
    verify(() => mockRepository.getProfile()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
