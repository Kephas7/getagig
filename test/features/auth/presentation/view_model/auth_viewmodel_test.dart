import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/login_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/logout_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        username: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        role: 'fallback',
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

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tUser = AuthEntity(
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123',
    role: 'user',
  );

  group('AuthViewModel', () {
    group('register', () {
      test(
        'should emit registered state when registration is successful',
        () async {
          when(
            () => mockRegisterUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.register(
            name: 'Test User',
            email: 'test@example.com',
            password: 'password123',
            role: 'user',
          );

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.registered);
          verify(() => mockRegisterUsecase(any())).called(1);
        },
      );

      test('should emit error state when registration fails', () async {
        const failure = ApiFailure(message: 'Email already exists');
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.register(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          role: 'user',
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Email already exists');
        verify(() => mockRegisterUsecase(any())).called(1);
      });

      test('should pass correct parameters to usecase', () async {
        RegisterParams? capturedParams;
        when(() => mockRegisterUsecase(any())).thenAnswer((invocation) {
          capturedParams = invocation.positionalArguments[0] as RegisterParams;
          return Future.value(const Right(true));
        });

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.register(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          role: 'admin',
        );

        expect(capturedParams?.username, 'Test User');
        expect(capturedParams?.email, 'test@example.com');
        expect(capturedParams?.password, 'password123');
        expect(capturedParams?.role, 'admin');
      });

      test('should emit loading state before registration', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        final viewModel = container.read(authViewModelProvider.notifier);
        final notifier = container.listen(authViewModelProvider, (_, state) {});

        final future = viewModel.register(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          role: 'user',
        );

        expect(notifier.read()!.status, AuthStatus.loading);

        await future;

        expect(notifier.read()!.status, AuthStatus.registered);
        verify(() => mockRegisterUsecase(any())).called(1);
      });
    });

    group('login', () {
      test(
        'should emit authenticated state with user when login is successful',
        () async {
          when(
            () => mockLoginUsecase(any()),
          ).thenAnswer((_) async => const Right(tUser));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.login(
            email: 'test@example.com',
            password: 'password123',
          );

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tUser);
          verify(() => mockLoginUsecase(any())).called(1);
        },
      );

      test('should emit error state when login fails', () async {
        const failure = ApiFailure(message: 'Invalid credentials');
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
        verify(() => mockLoginUsecase(any())).called(1);
      });

      test('should pass correct credentials to usecase', () async {
        LoginParams? capturedParams;
        when(() => mockLoginUsecase(any())).thenAnswer((invocation) {
          capturedParams = invocation.positionalArguments[0] as LoginParams;
          return Future.value(const Right(tUser));
        });

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(capturedParams?.email, 'test@example.com');
        expect(capturedParams?.password, 'password123');
      });

      test('should emit loading state before login', () async {
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Right(tUser));

        final viewModel = container.read(authViewModelProvider.notifier);
        final notifier = container.listen(authViewModelProvider, (_, state) {});

        final future = viewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(notifier.read()!.status, AuthStatus.loading);

        await future;

        expect(notifier.read()!.status, AuthStatus.authenticated);
        expect(notifier.read()!.user, tUser);
        verify(() => mockLoginUsecase(any())).called(1);
      });
    });

    group('getCurrentUser', () {
      test(
        'should emit authenticated state with user when user is found',
        () async {
          when(
            () => mockGetCurrentUserUsecase(),
          ).thenAnswer((_) async => const Right(tUser));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.getCurrentUser();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tUser);
          verify(() => mockGetCurrentUserUsecase()).called(1);
        },
      );

      test(
        'should emit unauthenticated state when user is not found',
        () async {
          const failure = ApiFailure(message: 'User not found');
          when(
            () => mockGetCurrentUserUsecase(),
          ).thenAnswer((_) async => const Left(failure));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.getCurrentUser();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.errorMessage, 'User not found');
          verify(() => mockGetCurrentUserUsecase()).called(1);
        },
      );

      test('should emit loading state before fetching user', () async {
        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => const Right(tUser));

        final viewModel = container.read(authViewModelProvider.notifier);
        final notifier = container.listen(authViewModelProvider, (_, state) {});

        final future = viewModel.getCurrentUser();

        expect(notifier.read()!.status, AuthStatus.loading);

        await future;

        expect(notifier.read()!.status, AuthStatus.authenticated);
        expect(notifier.read()!.user, tUser);
        verify(() => mockGetCurrentUserUsecase()).called(1);
      });
    });

    group('logout', () {
      test(
        'should emit unauthenticated state with null user when successful',
        () async {
          when(
            () => mockLogoutUsecase(),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.logout();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.user, isNull);
          verify(() => mockLogoutUsecase()).called(1);
        },
      );

      test('should emit error state when logout fails', () async {
        const failure = ApiFailure(message: 'Logout failed');
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.logout();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Logout failed');
        verify(() => mockLogoutUsecase()).called(1);
      });

      test('should emit loading state before logout', () async {
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Right(true));

        final viewModel = container.read(authViewModelProvider.notifier);
        final notifier = container.listen(authViewModelProvider, (_, state) {});

        final future = viewModel.logout();

        expect(notifier.read()!.status, AuthStatus.loading);

        await future;

        expect(notifier.read()!.status, AuthStatus.unauthenticated);
        expect(notifier.read()!.user, isNull);
        verify(() => mockLogoutUsecase()).called(1);
      });
    });
  });

  group('AuthState', () {
    test('should have correct initial values', () {
      const state = AuthState();

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      expect(state.errorMessage, isEmpty);
    });

    test('copyWith should update specified fields', () {
      const state = AuthState();

      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: tUser,
        errorMessage: 'test error',
      );

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.user, tUser);
      expect(newState.errorMessage, 'test error');
    });

    test('copyWith should preserve existing values when not specified', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        user: tUser,
        errorMessage: 'error',
      );

      final newState = state.copyWith(status: AuthStatus.loading);

      expect(newState.status, AuthStatus.loading);
      expect(newState.user, tUser);
      expect(newState.errorMessage, 'error');
    });

    test('props should contain all fields', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        user: tUser,
        errorMessage: 'error',
      );

      expect(state.props, [AuthStatus.authenticated, tUser, 'error']);
    });

    test('two states with same values should be equal', () {
      const state1 = AuthState(status: AuthStatus.authenticated, user: tUser);
      const state2 = AuthState(status: AuthStatus.authenticated, user: tUser);

      expect(state1, state2);
    });

    test('states with different values should not be equal', () {
      const state1 = AuthState(status: AuthStatus.authenticated, user: tUser);
      const state2 = AuthState(status: AuthStatus.unauthenticated, user: tUser);

      expect(state1, isNot(state2));
    });
  });
}
