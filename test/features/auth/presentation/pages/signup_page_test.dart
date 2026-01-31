import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/login_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/logout_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:getagig/features/auth/presentation/pages/signup_page.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

class FakeRoute extends Fake implements Route<dynamic> {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        username: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        role: 'musician',
      ),
    );
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createTestWidget({bool withObserver = false}) {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
      child: MaterialApp(
        home: const SignupPage(),
        navigatorObservers: withObserver ? [mockNavigatorObserver] : [],
      ),
    );
  }

  group('SignupPage UI Elements', () {
    testWidgets('should display sign up role label and choices', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign up as:'), findsOneWidget);
      expect(find.text('Musician'), findsOneWidget);
      expect(find.text('Organizer'), findsOneWidget);
    });

    testWidgets('should display four text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should display visibility icons for password fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should display terms checkbox and sign up button', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('I agree to the Terms & Conditions'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });
  });

  group('SignupPage Form Validation', () {
    testWidgets('should show error if user has not agreed to terms', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please agree to the Terms & Conditions'),
        findsOneWidget,
      );
    });

    testWidgets('should show error for empty name when agreed to terms', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.enterText(find.byType(TextFormField).at(3), 'password1');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.enterText(find.byType(TextFormField).at(3), 'password2');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('SignupPage Form Submission', () {
    testWidgets('should call register usecase when form is valid', (
      tester,
    ) async {
      final completer = Completer<Either<Failures, bool>>();
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.enterText(find.byType(TextFormField).at(3), 'password1');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      verify(() => mockRegisterUsecase(any())).called(1);
    });

    testWidgets('should call register with correct params', (tester) async {
      final completer = Completer<Either<Failures, bool>>();

      RegisterParams? capturedParams;
      when(() => mockRegisterUsecase(any())).thenAnswer((invocation) {
        capturedParams = invocation.positionalArguments[0] as RegisterParams;
        return completer.future;
      });

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Smith');
      await tester.enterText(find.byType(TextFormField).at(1), 'jane@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'mypassword');
      await tester.enterText(find.byType(TextFormField).at(3), 'mypassword');

      await tester.ensureVisible(find.text('Organizer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Organizer'));
      await tester.pump();

      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(capturedParams?.username, 'Jane Smith');
      expect(capturedParams?.email, 'jane@test.com');
      expect(capturedParams?.password, 'mypassword');
      expect(capturedParams?.role, 'organizer');
    });

    testWidgets('should show loading indicator while registering', (
      tester,
    ) async {
      final completer = Completer<Either<Failures, bool>>();
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.enterText(find.byType(TextFormField).at(3), 'password1');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success snackbar and pop on success', (
      tester,
    ) async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget(withObserver: true));

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.enterText(find.byType(TextFormField).at(3), 'password1');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });
  });
}
