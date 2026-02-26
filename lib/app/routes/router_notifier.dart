import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _splashTimerComplete = false;

  RouterNotifier(this._ref) {
    // Minimum splash display time
    Future.delayed(const Duration(seconds: 2), () {
      _splashTimerComplete = true;
      notifyListeners();
    });

    // Listen to auth state changes and notify GoRouter
    _ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }

  bool get isReady {
    final status = authStatus;
    final authResolved =
        status != AuthStatus.initial && status != AuthStatus.loading;
    return _splashTimerComplete && authResolved;
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

