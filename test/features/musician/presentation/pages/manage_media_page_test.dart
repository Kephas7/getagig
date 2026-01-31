import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/musician/presentation/pages/manage_media_page.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/usecases/get_profile_usecase.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

class FakeFile extends Fake implements File {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  const tMusician = MusicianEntity(
    id: 'id1',
    userId: 'user1',
    stageName: 'Stage One',
    profilePicture: null,
    bio: null,
    phone: '1234567890',
    location: {'city': 'Kathmandu', 'country': 'Nepal'},
    genres: [],
    instruments: [],
    experienceYears: 2,
    hourlyRate: null,
    photos: [],
    videos: [],
    audioSamples: [],
    isAvailable: true,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  testWidgets('shows empty state and upload sheet for photos', (tester) async {
    final mockGetProfile = MockGetProfileUseCase();
    when(
      () => mockGetProfile(),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'Not found')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProfileUseCaseProvider.overrideWithValue(mockGetProfile),
        ],
        child: const MaterialApp(
          home: ManageMediaPage(mediaType: MediaType.photos, mediaUrls: []),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No Photos Yet'), findsOneWidget);
    expect(find.text('Upload Photos'), findsOneWidget);

    await tester.tap(find.text('Upload Photos'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);

    await tester.tap(find.text('Choose from Gallery'));
    await tester.pumpAndSettle();
  });

  testWidgets('shows grid when photos exist and badge count shows', (
    tester,
  ) async {
    const musicianWithPhotos = MusicianEntity(
      id: 'id1',
      userId: 'user1',
      stageName: 'Stage One',
      profilePicture: null,
      bio: null,
      phone: '1234567890',
      location: {'city': 'Kathmandu', 'country': 'Nepal'},
      genres: [],
      instruments: [],
      experienceYears: 2,
      hourlyRate: null,
      photos: ['p1.jpg', 'p2.jpg'],
      videos: [],
      audioSamples: [],
      isAvailable: true,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-02',
    );

    final mockGetProfile = MockGetProfileUseCase();
    when(
      () => mockGetProfile(),
    ).thenAnswer((_) async => const Right(musicianWithPhotos));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getProfileUseCaseProvider.overrideWithValue(mockGetProfile),
        ],
        child: const MaterialApp(
          home: ManageMediaPage(mediaType: MediaType.photos, mediaUrls: []),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('2 / 10'), findsOneWidget);

    expect(find.byType(GridView), findsOneWidget);

    expect(find.byType(CachedNetworkImage), findsNWidgets(2));
  });
}
