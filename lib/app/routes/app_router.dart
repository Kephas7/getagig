import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:getagig/app/routes/route_constants.dart';
import 'package:getagig/app/routes/router_notifier.dart';
import 'package:getagig/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/pages/register_page.dart';
import 'package:getagig/features/auth/presentation/pages/reset_password_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';

import 'package:getagig/features/dashboard/presentation/pages/dashboard_router.dart';
import 'package:getagig/features/splash/presentation/pages/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final currentPath = state.uri.path;

      if (!routerNotifier.isReady) {
        return currentPath == RouteConstants.splash
            ? null
            : RouteConstants.splash;
      }

      final isAuthenticated = routerNotifier.isAuthenticated;
      final authStatus = routerNotifier.authStatus;

      const staticPublicRoutes = [
        RouteConstants.splash,
        RouteConstants.login,
        RouteConstants.signup,
        RouteConstants.forgotPassword,
      ];
      final isResetPasswordPath = currentPath.startsWith(
        '${RouteConstants.resetPassword}/',
      );
      final isPublicRoute =
          staticPublicRoutes.contains(currentPath) || isResetPasswordPath;

      if (isAuthenticated) {
        if (isPublicRoute) {
          return RouteConstants.dashboard;
        }
        return null;
      }

      if (authStatus == AuthStatus.registered &&
          currentPath != RouteConstants.login) {
        return RouteConstants.login;
      }

      if (isPublicRoute) {
        if (currentPath == RouteConstants.splash) {
          return RouteConstants.login;
        }
        return null;
      }

      return RouteConstants.login;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        name: RouteNames.signup,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '${RouteConstants.resetPassword}/:token',
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final token = state.pathParameters['token'];
          return ResetPasswordPage(token: token ?? '');
        },
      ),
      GoRoute(
        path: RouteConstants.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardRouter(),
      ),
    ],
  );
});
