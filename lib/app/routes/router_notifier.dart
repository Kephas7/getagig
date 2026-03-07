import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _splashTimerComplete = false;
  bool _hasResolvedInitialAuth = false;

  RouterNotifier(this._ref) {
    final initialStatus = _ref.read(authViewModelProvider).status;
    _hasResolvedInitialAuth =
        initialStatus != AuthStatus.initial &&
        initialStatus != AuthStatus.loading;

    // Minimum splash display time
    Future.delayed(const Duration(seconds: 2), () {
      _splashTimerComplete = true;
      notifyListeners();
    });

    // Listen to auth state changes and notify GoRouter
    _ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status != AuthStatus.initial &&
          next.status != AuthStatus.loading) {
        _hasResolvedInitialAuth = true;
      }

      if (previous?.status != next.status ||
          previous?.user?.role != next.user?.role) {
        notifyListeners();
      }
    });
  }

  bool get isReady {
    return _splashTimerComplete && _hasResolvedInitialAuth;
  }

  bool get isAuthenticated {
    final authState = _ref.read(authViewModelProvider);
    return authState.status == AuthStatus.authenticated &&
        authState.user != null;
  }

  AuthStatus get authStatus {
    return _ref.read(authViewModelProvider).status;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
