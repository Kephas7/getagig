import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ProviderContainer container;
  late MockAuthRepository mockRepository;

  const tUser = AuthEntity(
    username: 'testuser',
    email: 'test@example.com',
    role: 'musician',
  );

  setUp(() {
    mockRepository = MockAuthRepository();

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
    );

    addTearDown(container.dispose);
  });

  test('login updates state to authenticated on success', () async {
    when(
      () => mockRepository.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => const Right(tUser));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.login(email: 'test@example.com', password: 'password123');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, tUser);
    expect(state.errorMessage, isNull);
    verify(
      () => mockRepository.login('test@example.com', 'password123'),
    ).called(1);
  });

  test('login updates state to error on failure', () async {
    const failure = ApiFailure(message: 'Invalid credentials');
    when(
      () => mockRepository.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.login(email: 'test@example.com', password: 'password123');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Invalid credentials');
    verify(
      () => mockRepository.login('test@example.com', 'password123'),
    ).called(1);
  });

  test('register updates state to registered on success', () async {
    when(
      () => mockRepository.register(
        const AuthEntity(
          username: 'new-user',
          email: 'new@example.com',
          password: 'secret123',
          role: 'organizer',
        ),
      ),
    ).thenAnswer((_) async => const Right(true));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.register(
      name: 'new-user',
      email: 'new@example.com',
      password: 'secret123',
      role: 'organizer',
    );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.registered);
    expect(state.errorMessage, isNull);
    verify(
      () => mockRepository.register(
        const AuthEntity(
          username: 'new-user',
          email: 'new@example.com',
          password: 'secret123',
          role: 'organizer',
        ),
      ),
    ).called(1);
  });

  test('getCurrentUser updates state to authenticated on success', () async {
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Right(tUser));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.getCurrentUser();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, tUser);
    expect(state.errorMessage, isNull);
    verify(() => mockRepository.getCurrentUser()).called(1);
  });

  test('getCurrentUser updates state to unauthenticated on failure', () async {
    const failure = ApiFailure(message: 'User not authenticated');
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Left(failure));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.getCurrentUser();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.errorMessage, 'User not authenticated');
    verify(() => mockRepository.getCurrentUser()).called(1);
  });

  test('logout clears user and updates state to unauthenticated', () async {
    when(
      () => mockRepository.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => const Right(tUser));
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Right(true));

    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.login(email: 'test@example.com', password: 'password123');
    await notifier.logout();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.user, isNull);
    expect(state.errorMessage, isNull);
    verify(
      () => mockRepository.login('test@example.com', 'password123'),
    ).called(1);
    verify(() => mockRepository.logout()).called(1);
  });
}
