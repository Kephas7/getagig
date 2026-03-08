import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/admin/admin_providers.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/usecases/get_admin_users_usecase.dart';
import 'package:getagig/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/pages/dashboard_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAdminUsersUseCase extends Mock implements GetAdminUsersUseCase {}

class UnauthenticatedAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated, user: null);
  }
}

class AdminAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: AuthEntity(
        username: 'root',
        email: 'root@getagig.com',
        role: 'admin',
      ),
    );
  }
}

void main() {
  late MockGetAdminUsersUseCase mockGetAdminUsersUseCase;

  setUp(() {
    mockGetAdminUsersUseCase = MockGetAdminUsersUseCase();
    when(
      () => mockGetAdminUsersUseCase(const GetAdminUsersParams()),
    ).thenAnswer((_) async => const Right(<AdminUserEntity>[]));
  });

  testWidgets('shows not authenticated state when user is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(UnauthenticatedAuthViewModel.new),
        ],
        child: const MaterialApp(home: DashboardRouter()),
      ),
    );

    await tester.pump();

    expect(find.text('Not authenticated'), findsOneWidget);
  });

  testWidgets('routes admin user to admin dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(AdminAuthViewModel.new),
          getAdminUsersUseCaseProvider.overrideWithValue(
            mockGetAdminUsersUseCase,
          ),
        ],
        child: const MaterialApp(home: DashboardRouter()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(AdminDashboardPage), findsOneWidget);
    expect(find.text('Admin Control Center'), findsOneWidget);
  });
}
