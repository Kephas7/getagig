import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/splash/presentation/pages/splash_page.dart';

class FakeSplashAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.initial);
  }

  @override
  Future<void> getCurrentUser() async {}
}

void main() {
  testWidgets('renders branding and progress indicator', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(FakeSplashAuthViewModel.new),
        ],
        child: const MaterialApp(home: SplashPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Get-a-Gig'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
