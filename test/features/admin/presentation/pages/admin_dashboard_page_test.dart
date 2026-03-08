import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/app/theme/app_theme.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/admin/admin_providers.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/usecases/get_admin_users_usecase.dart';
import 'package:getagig/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAdminUsersUseCase extends Mock implements GetAdminUsersUseCase {}

void main() {
  late MockGetAdminUsersUseCase mockGetAdminUsersUseCase;

  setUpAll(() {
    registerFallbackValue(const GetAdminUsersParams());
  });

  Finder _verticalScrollable() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          (widget.axisDirection == AxisDirection.down ||
              widget.axisDirection == AxisDirection.up),
    );
  }

  Finder _horizontalScrollable() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          (widget.axisDirection == AxisDirection.left ||
              widget.axisDirection == AxisDirection.right),
    );
  }

  Future<void> settleDashboard(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> tapFilterChip(WidgetTester tester, String label) async {
    final chip = find.widgetWithText(ChoiceChip, label);

    if (_horizontalScrollable().evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        chip,
        220,
        scrollable: _horizontalScrollable(),
      );
    }

    await tester.tap(chip, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 180));
  }

  Future<void> pumpAdminDashboard(
    WidgetTester tester, {
    required ThemeData theme,
    bool disableRetry = false,
  }) async {
    final app = MaterialApp(theme: theme, home: const AdminDashboardPage());

    await tester.pumpWidget(
      disableRetry
          ? ProviderScope(
              retry: (_, __) => null,
              overrides: [
                getAdminUsersUseCaseProvider.overrideWithValue(
                  mockGetAdminUsersUseCase,
                ),
              ],
              child: app,
            )
          : ProviderScope(
              overrides: [
                getAdminUsersUseCaseProvider.overrideWithValue(
                  mockGetAdminUsersUseCase,
                ),
              ],
              child: app,
            ),
    );
    await settleDashboard(tester);
  }

  AdminUserEntity buildUser({
    required String id,
    required String username,
    required String role,
    bool isVerified = false,
    bool verificationRequested = false,
    String? profileId,
  }) {
    return AdminUserEntity(
      id: id,
      username: username,
      email: '$id@example.com',
      role: role,
      isVerified: isVerified,
      verificationRequested: verificationRequested,
      profileId: profileId,
      createdAt: DateTime(2026, 1, 5),
    );
  }

  setUp(() {
    mockGetAdminUsersUseCase = MockGetAdminUsersUseCase();
  });

  testWidgets('renders overview and user cards from loaded state', (
    tester,
  ) async {
    final users = [
      buildUser(
        id: 'u1',
        username: 'Maya Strings',
        role: 'musician',
        isVerified: true,
        profileId: 'm1',
      ),
      buildUser(
        id: 'u2',
        username: 'Pulse Events',
        role: 'organizer',
        verificationRequested: true,
        profileId: 'o1',
      ),
      buildUser(id: 'u3', username: 'Root Admin', role: 'admin'),
    ];

    when(
      () => mockGetAdminUsersUseCase(any()),
    ).thenAnswer((_) async => Right(users));

    await pumpAdminDashboard(tester, theme: getLightTheme());

    expect(find.text('Admin Control Center'), findsOneWidget);
    expect(find.text('Platform Snapshot'), findsOneWidget);
    expect(find.text('Maya Strings'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pulse Events'),
      300,
      scrollable: _verticalScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Pulse Events'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Root Admin'),
      300,
      scrollable: _verticalScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Root Admin'), findsOneWidget);

    verify(() => mockGetAdminUsersUseCase(any())).called(1);
  });

  testWidgets('musician filter only shows musician accounts', (tester) async {
    final users = [
      buildUser(
        id: 'u1',
        username: 'Maya Strings',
        role: 'musician',
        isVerified: true,
        profileId: 'm1',
      ),
      buildUser(
        id: 'u2',
        username: 'Pulse Events',
        role: 'organizer',
        verificationRequested: true,
        profileId: 'o1',
      ),
      buildUser(id: 'u3', username: 'Root Admin', role: 'admin'),
    ];

    when(
      () => mockGetAdminUsersUseCase(any()),
    ).thenAnswer((_) async => Right(users));

    await pumpAdminDashboard(tester, theme: getLightTheme());

    await tapFilterChip(tester, 'Musicians (1)');

    expect(find.text('Maya Strings'), findsOneWidget);
    expect(find.text('Pulse Events'), findsNothing);
    expect(find.text('Root Admin'), findsNothing);
  });

  testWidgets('pending filter exposes approve and deny verification actions', (
    tester,
  ) async {
    final users = [
      buildUser(
        id: 'u1',
        username: 'Maya Strings',
        role: 'musician',
        isVerified: true,
        profileId: 'm1',
      ),
      buildUser(
        id: 'u2',
        username: 'Pulse Events',
        role: 'organizer',
        verificationRequested: true,
        profileId: 'o1',
      ),
    ];

    when(
      () => mockGetAdminUsersUseCase(any()),
    ).thenAnswer((_) async => Right(users));

    await pumpAdminDashboard(tester, theme: getLightTheme());

    await tapFilterChip(tester, 'Pending (1)');
    await tester.scrollUntilVisible(
      find.text('Approve'),
      260,
      scrollable: _verticalScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Pulse Events'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Deny'), findsOneWidget);
  });

  testWidgets('shows empty-state message when filter has no matches', (
    tester,
  ) async {
    final users = [buildUser(id: 'u3', username: 'Root Admin', role: 'admin')];

    when(
      () => mockGetAdminUsersUseCase(any()),
    ).thenAnswer((_) async => Right(users));

    await pumpAdminDashboard(tester, theme: getLightTheme());

    await tapFilterChip(tester, 'Pending (0)');

    expect(find.text('No users found for this filter.'), findsOneWidget);
  });

  testWidgets('renders error panel with retry action in dark mode', (
    tester,
  ) async {
    when(
      () => mockGetAdminUsersUseCase(any()),
    ).thenAnswer((_) async => const Left(ApiFailure(message: 'Backend down')));

    await pumpAdminDashboard(tester, theme: getDarkTheme(), disableRetry: true);

    expect(find.text('Unable to load users'), findsOneWidget);
    expect(find.text('Backend down'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
