 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/auth/presentation/pages/register_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class FakeRegisterAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {}
}

void main() {
  Future<void> pumpRegisterPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(FakeRegisterAuthViewModel.new),
        ],
        child: const MaterialApp(home: RegisterPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  testWidgets('renders register form controls', (tester) async {
    await pumpRegisterPage(tester);

    expect(find.text('Start Gigging With Us'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Sign up as:'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Musician'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Organizer'), findsOneWidget);
    expect(find.text('I agree to the Terms & Conditions'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Already have an account? Login'),
      findsOneWidget,
    );
  });

  testWidgets('switching to organizer updates role helper text', (
    tester,
  ) async {
    await pumpRegisterPage(tester);

    expect(find.text('Looking for gig opportunities'), findsOneWidget);
    expect(find.text('Hiring musicians for events'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Organizer'));
    await tester.pump();

    expect(find.text('Looking for gig opportunities'), findsNothing);
    expect(find.text('Hiring musicians for events'), findsOneWidget);
  });
}
