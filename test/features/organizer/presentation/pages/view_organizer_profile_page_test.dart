import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/presentation/pages/manage_organizer_media_page.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

const _tOrganizer = OrganizerEntity(
  id: 'org-id-1',
  userId: 'user-id-1',
  organizationName: 'Blue Note Events',
  profilePicture: null,
  bio: 'We organize live music events.',
  contactPerson: 'Jane Organizer',
  phone: '9800000001',
  email: 'jane@bluenote.com',
  location: 'Kathmandu, Nepal',
  organizationType: 'Festival',
  eventTypes: ['Concert'],
  verificationDocuments: ['/uploads/organizers/documents/doc-1.pdf'],
  website: 'https://bluenote.com',
  photos: ['/uploads/organizers/photos/photo-1.jpg'],
  videos: ['/uploads/organizers/videos/video-1.mp4'],
  isVerified: false,
  verificationRequested: false,
  isActive: true,
  createdAt: '2026-01-01',
  updatedAt: '2026-01-02',
);

class _FakeOrganizerProfileViewModel extends OrganizerProfileViewModel {
  @override
  OrganizerProfileState build() {
    return const OrganizerProfileState(
      status: OrganizerProfileStatus.loaded,
      profile: _tOrganizer,
      errorMessage: null,
    );
  }

  @override
  Future<void> getProfile() async {}

  @override
  Future<void> getProfileById(String id) async {}
}

void main() {
  Future<void> pumpStableFrames(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
  }

  Widget createTestWidget({String? organizerId}) {
    return ProviderScope(
      overrides: [
        organizerProfileViewModelProvider.overrideWith(
          _FakeOrganizerProfileViewModel.new,
        ),
      ],
      child: MaterialApp(
        home: ViewOrganizerProfilePage(organizerId: organizerId),
      ),
    );
  }

  testWidgets('opens photos media page in owner mode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpStableFrames(tester);

    final photosTile = find.widgetWithText(ListTile, 'Photos');
    await tester.ensureVisible(photosTile);
    await tester.tap(photosTile);
    await pumpStableFrames(tester);

    expect(find.byType(ManageOrganizerMediaPage), findsOneWidget);

    final page = tester.widget<ManageOrganizerMediaPage>(
      find.byType(ManageOrganizerMediaPage),
    );
    expect(page.mediaType, OrganizerMediaType.photos);
    expect(page.isOwner, isTrue);
  });

  testWidgets('opens videos media page in owner mode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await pumpStableFrames(tester);

    final videosTile = find.widgetWithText(ListTile, 'Videos');
    await tester.ensureVisible(videosTile);
    await tester.tap(videosTile);
    await pumpStableFrames(tester);

    expect(find.byType(ManageOrganizerMediaPage), findsOneWidget);

    final page = tester.widget<ManageOrganizerMediaPage>(
      find.byType(ManageOrganizerMediaPage),
    );
    expect(page.mediaType, OrganizerMediaType.videos);
    expect(page.isOwner, isTrue);
  });

  testWidgets('opens documents page in read-only mode for public profile', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget(organizerId: 'public-org-id'));
    await pumpStableFrames(tester);

    final docsTile = find.widgetWithText(ListTile, 'Documents');
    await tester.ensureVisible(docsTile);
    await tester.tap(docsTile);
    await pumpStableFrames(tester);

    expect(find.byType(ManageOrganizerMediaPage), findsOneWidget);

    final page = tester.widget<ManageOrganizerMediaPage>(
      find.byType(ManageOrganizerMediaPage),
    );
    expect(page.mediaType, OrganizerMediaType.documents);
    expect(page.isOwner, isFalse);
  });
}
