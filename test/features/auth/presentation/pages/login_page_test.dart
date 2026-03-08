import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/core/services/security/biometric_auth_service.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class MockUserSessionService extends Mock implements UserSessionService {}

class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  Future<void> getCurrentUser() async {}

  @override
  Future<void> login({required String email, required String password}) async {}
}

void main() {
  late MockBiometricAuthService mockBiometricAuthService;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockBiometricAuthService = MockBiometricAuthService();
    mockUserSessionService = MockUserSessionService();

    when(
      () => mockBiometricAuthService.isFingerprintSupported(),
    ).thenAnswer((_) async => false);
    when(
      () => mockUserSessionService.isBiometricLoginEnabled(),
    ).thenAnswer((_) async => false);
  });

  testWidgets('renders login form controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(FakeAuthViewModel.new),
          biometricAuthServiceProvider.overrideWithValue(
            mockBiometricAuthService,
          ),
          userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('WELCOME'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Create Account'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Forgot Password?'), findsOneWidget);
  });
}
