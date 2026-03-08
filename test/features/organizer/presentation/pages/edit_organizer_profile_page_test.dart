import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/presentation/pages/edit_organizer_profile_page.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

class FakeOrganizerProfileViewModel extends OrganizerProfileViewModel {
  @override
  OrganizerProfileState build() {
    return const OrganizerProfileState(status: OrganizerProfileStatus.initial);
  }
}

void main() {
  const organizer = OrganizerEntity(
    id: 'org-1',
    userId: 'user-1',
    organizationName: 'Pulse Events',
    bio: 'Event host',
    contactPerson: 'Anita',
    phone: '9800001111',
    email: 'pulse@example.com',
    location: 'Kathmandu',
    organizationType: 'Festival',
    eventTypes: ['Concert', 'Wedding'],
    verificationDocuments: [],
    website: 'https://pulse.example.com',
    photos: [],
    videos: [],
    isVerified: false,
    verificationRequested: false,
    isActive: true,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-02T00:00:00.000Z',
  );

  testWidgets('renders organizer edit profile sections and save action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          organizerProfileViewModelProvider.overrideWith(
            FakeOrganizerProfileViewModel.new,
          ),
        ],
        child: const MaterialApp(
          home: EditOrganizerProfilePage(organizer: organizer),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Edit Organizer Profile'), findsOneWidget);
    expect(find.text('Organization'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Save Changes'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Save Changes'), findsOneWidget);
  });
}
