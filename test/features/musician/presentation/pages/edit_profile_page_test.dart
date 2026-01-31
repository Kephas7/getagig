import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/musician/presentation/pages/edit_profile_page.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';

void main() {
  const tMusician = MusicianEntity(
    id: 'id1',
    userId: 'user1',
    stageName: 'Stage One',
    profilePicture: null,
    bio: 'Short bio',
    phone: '1234567890',
    location: {'city': 'Kathmandu', 'state': 'Bagmati', 'country': 'Nepal'},
    genres: ['Rock'],
    instruments: ['Guitar'],
    experienceYears: 5,
    hourlyRate: 75.0,
    photos: [],
    videos: [],
    audioSamples: [],
    isAvailable: true,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-02',
  );

  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(home: EditProfilePage(musician: tMusician)),
    );
  }

  testWidgets('renders form fields with initial musician values', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Stage One'), findsOneWidget);
    expect(find.text('Short bio'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
    expect(find.text('Bagmati'), findsOneWidget);
    expect(find.text('Nepal'), findsOneWidget);
    expect(find.text('Rock'), findsOneWidget);
    expect(find.text('Guitar'), findsOneWidget);
  });



  testWidgets('shows snack bar when genres deselected', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Deselect the only selected genre (use FilterChip finder and ensure visible)
    final rockChip = find.widgetWithText(FilterChip, 'Rock');
    expect(rockChip, findsOneWidget);
    await tester.ensureVisible(rockChip);
    await tester.pumpAndSettle();

    await tester.tap(rockChip);
    await tester.pumpAndSettle();

    // Attempt to update
    await tester.ensureVisible(find.text('Update Profile'));
    await tester.tap(find.text('Update Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Please select at least one genre'), findsOneWidget);
  });

  testWidgets('shows snack bar when instruments deselected', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Deselect the only selected instrument
    final guitarChip = find.widgetWithText(FilterChip, 'Guitar');
    expect(guitarChip, findsOneWidget);
    await tester.ensureVisible(guitarChip);
    await tester.pumpAndSettle();

    await tester.tap(guitarChip);
    await tester.pumpAndSettle();

    // Make sure genres are still selected so we get instrument check
    expect(find.text('Please select at least one genre'), findsNothing);

    // Attempt to update
    await tester.ensureVisible(find.text('Update Profile'));
    await tester.tap(find.text('Update Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Please select at least one instrument'), findsOneWidget);
  });
}
