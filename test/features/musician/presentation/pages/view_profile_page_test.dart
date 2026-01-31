import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/usecases/get_profile_usecase.dart';
import 'package:getagig/features/musician/domain/usecases/update_availability_usecase.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateAvailabilityUseCase extends Mock
    implements UpdateAvailabilityUseCase {}

void main() {
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateAvailabilityUseCase mockUpdateAvailabilityUseCase;

  setUpAll(() {
    registerFallbackValue(const UpdateAvailabilityParams(isAvailable: true));
  });

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateAvailabilityUseCase = MockUpdateAvailabilityUseCase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        getProfileUseCaseProvider.overrideWithValue(mockGetProfileUseCase),
        updateAvailabilityUseCaseProvider.overrideWithValue(
          mockUpdateAvailabilityUseCase,
        ),
      ],
      child: const MaterialApp(home: ViewProfilePage()),
    );
  }

  const tMusician = MusicianEntity(
    id: 'id1',
    userId: 'user1',
    stageName: 'Stage One',
    profilePicture: null,
    bio: 'Bio details',
    phone: '1234567890',
    location: {'city': 'Kathmandu', 'country': 'Nepal'},
    genres: ['Rock', 'Pop'],
    instruments: ['Guitar', 'Drums'],
    experienceYears: 5,
    hourlyRate: 75.0,
    photos: ['p1', 'p2'],
    videos: ['v1'],
    audioSamples: ['a1'],
    isAvailable: true,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  testWidgets('shows create profile when no profile found', (tester) async {
    when(
      () => mockGetProfileUseCase(),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'Not found')));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Please create your musician profile'), findsOneWidget);
    expect(find.text('Create Profile'), findsOneWidget);
  });

  testWidgets('shows loading indicator while fetching profile', (tester) async {
    final completer = Completer<Either<Failures, MusicianEntity>>();
    when(() => mockGetProfileUseCase()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createTestWidget());

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right(tMusician));
    await tester.pumpAndSettle();
  });

  testWidgets('displays profile details when loaded', (tester) async {
    when(
      () => mockGetProfileUseCase(),
    ).thenAnswer((_) async => const Right(tMusician));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Stage One'), findsOneWidget);
    expect(find.text('Available for Gigs'), findsOneWidget);
    expect(find.text('Bio details'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Rock'), findsOneWidget);
    expect(find.text('Guitar'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows error message and retry button when failure occurs', (
    tester,
  ) async {
    when(
      () => mockGetProfileUseCase(),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'Server error')));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => mockGetProfileUseCase()).called(2);
  });

  testWidgets('tapping availability button calls updateAvailability usecase', (
    tester,
  ) async {
    when(
      () => mockGetProfileUseCase(),
    ).thenAnswer((_) async => const Right(tMusician));
    when(
      () => mockUpdateAvailabilityUseCase(any()),
    ).thenAnswer((_) async => const Right(tMusician));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Mark as Unavailable'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark as Unavailable'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Unavailable'));
    await tester.pumpAndSettle();

    verify(() => mockUpdateAvailabilityUseCase(any())).called(1);
  });
}
