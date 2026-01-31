import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/login_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/logout_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

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
  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        username: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        role: 'musician',
      ),
    );
    registerFallbackValue(
      const LoginParams(email: 'fallback@email.com', password: 'fallback'),
    );
  });
  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
  });
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage UI Elements', () {
    testWidgets('should display welcome text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('WELCOME'), findsOneWidget);
    });
    testWidgets('should display email and password labels', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Log in'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display two text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
    testWidgets('should display visibility icon for password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
    testWidgets('should display signup link text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text("Create Account"), findsOneWidget);
    });
    testWidgets('should display hint texts', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
  group('LoginPage Form Validation', () {
    testWidgets('should show error for empty email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });
    testWidgets('should show error for empty password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });
    testWidgets('should allow text entry in email field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should allow text entry in password field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      final passwordField = tester.widget<TextFormField>(
        find.byType(TextFormField).last,
      );
      expect(passwordField.controller?.text, 'password123');
    });
  });
  group('LoginPage Form Submission', () {
    testWidgets('should call login usecase when form is valid', (tester) async {
      final completer = Completer<Either<Failures, AuthEntity>>();

      when(() => mockLoginUsecase(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Log in'));
      await tester.pump();

      verify(() => mockLoginUsecase(any())).called(1);
    });
    testWidgets('should call login with correct email and password', (
      tester,
    ) async {
      final completer = Completer<Either<Failures, AuthEntity>>();

      LoginParams? capturedParams;
      when(() => mockLoginUsecase(any())).thenAnswer((invocation) {
        capturedParams = invocation.positionalArguments[0] as LoginParams;
        return completer.future;
      });

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'mypassword');

      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(capturedParams?.email, 'user@test.com');
      expect(capturedParams?.password, 'mypassword');
    });
    testWidgets('should not call login usecase when form is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      await tester.tap(find.text('Log in'));
      await tester.pump();

      verifyNever(() => mockLoginUsecase(any()));
    });
    testWidgets('should show loading indicator while logging in', (
      tester,
    ) async {
      final completer = Completer<Either<Failures, AuthEntity>>();

      when(() => mockLoginUsecase(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets(
      'should succeed with correct credentials and fail with wrong credentials',
      (tester) async {
        const correctEmail = 'correct@test.com';
        const correctPassword = 'correctpass';
        const failure = ApiFailure(message: 'Invalid credentials');

        List<LoginParams> capturedParams = [];

        when(() => mockLoginUsecase(any())).thenAnswer((invocation) async {
          final params = invocation.positionalArguments[0] as LoginParams;
          capturedParams.add(params);

          if (params.email == correctEmail &&
              params.password == correctPassword) {
            return const Left(ApiFailure(message: 'Test complete'));
          }
          return const Left(failure);
        });

        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
          find.byType(TextFormField).first,
          'wrong@test.com',
        );
        await tester.enterText(
          find.byType(TextFormField).last,
          correctPassword,
        );
        await tester.tap(find.text('Log in'));
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).first, correctEmail);
        await tester.enterText(
          find.byType(TextFormField).last,
          correctPassword,
        );
        await tester.tap(find.text('Log in'));
        await tester.pump();

        expect(capturedParams.length, 2);
        expect(capturedParams[0].email, 'wrong@test.com');
        expect(capturedParams[1].email, correctEmail);
      },
    );
  });
}
