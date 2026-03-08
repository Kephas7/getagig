import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/applications/application_providers.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:getagig/features/applications/presentation/pages/my_applications_page.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyApplicationsUseCase extends Mock
    implements GetMyApplicationsUseCase {}

void main() {
  late MockGetMyApplicationsUseCase mockGetMyApplicationsUseCase;

  setUp(() {
    mockGetMyApplicationsUseCase = MockGetMyApplicationsUseCase();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getMyApplicationsUseCaseProvider.overrideWithValue(
            mockGetMyApplicationsUseCase,
          ),
        ],
        child: const MaterialApp(home: MyApplicationsPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  testWidgets('shows empty state when no applications are returned', (
    tester,
  ) async {
    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => const Right(<ApplicationEntity>[]));

    await pumpPage(tester);

    expect(find.text('My Applications'), findsOneWidget);
    expect(find.text('No applications yet'), findsOneWidget);
    expect(find.text('Browse Opportunities'), findsOneWidget);
  });

  testWidgets('shows application card and status chips when data exists', (
    tester,
  ) async {
    final applications = [
      ApplicationEntity(
        id: 'app-1',
        status: 'pending',
        gig: GigEntity(
          id: 'gig-1',
          title: 'Rock Night',
          description: 'Live session',
          location: 'Kathmandu',
          genres: const ['Rock'],
          instruments: const ['Guitar'],
          payRate: 1800,
          eventType: 'Concert',
          status: 'open',
          organizerName: 'Stage House',
        ),
        createdAt: DateTime(2026, 2, 5),
      ),
      const ApplicationEntity(id: 'app-2', status: 'accepted'),
    ];

    when(
      () => mockGetMyApplicationsUseCase(),
    ).thenAnswer((_) async => Right(applications));

    await pumpPage(tester);

    expect(find.text('Rock Night'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });
}
