import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/presentation/pages/edit_profile_page.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';

class FakeMusicianProfileViewModel extends MusicianProfileViewModel {
  @override
  MusicianProfileState build() {
    return const MusicianProfileState(status: MusicianProfileStatus.initial);
  }
}

void main() {
  const musician = MusicianEntity(
    id: 'mus-1',
    userId: 'user-1',
    stageName: 'Sison',
    bio: 'Live performer',
    phone: '9800000000',
    location: 'Kathmandu',
    genres: ['Rock', 'Pop'],
    instruments: ['Guitar', 'Vocals'],
    experienceYears: 5,
    hourlyRate: 9000,
    photos: [],
    videos: [],
    audioSamples: [],
    isVerified: false,
    verificationRequested: false,
    isAvailable: true,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
  );

  testWidgets('renders musician edit profile sections and save action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          musicianProfileViewModelProvider.overrideWith(
            FakeMusicianProfileViewModel.new,
          ),
        ],
        child: const MaterialApp(home: EditProfilePage(musician: musician)),
      ),
    );

    await tester.pump();

    expect(find.text('Edit Musician Profile'), findsOneWidget);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Style & Skills'), findsOneWidget);
    expect(find.text('Experience & Rate'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Update Profile'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Update Profile'), findsOneWidget);
  });
}
