import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/login_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/logout_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/register_usecase.dart';
import 'package:getagig/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  bool _isResolvingCurrentUser = false;

  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        username: name,
        email: email,
        password: password,
        role: role,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _forgotPasswordUsecase(
      ForgotPasswordParams(email: email),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.forgotPasswordSuccess,
        errorMessage: null,
      ),
    );
  }

  Future<void> resetPassword(String token, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.resetPasswordSuccess,
        errorMessage: null,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    if (_isResolvingCurrentUser) return;
    _isResolvingCurrentUser = true;

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _getCurrentUserUsecase().timeout(
        const Duration(seconds: 12),
      );

      result.fold(
        (failure) => state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
        (user) => state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } on TimeoutException {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Startup auth check timed out.',
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Unable to verify authentication.',
      );
    } finally {
      _isResolvingCurrentUser = false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }
}
