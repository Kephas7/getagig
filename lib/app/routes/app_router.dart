import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:getagig/app/routes/route_constants.dart';
import 'package:getagig/app/routes/router_notifier.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:getagig/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/auth/presentation/pages/register_page.dart';
import 'package:getagig/features/auth/presentation/pages/reset_password_page.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/pages/musician_dashboard_page.dart';
import 'package:getagig/features/dashboard/presentation/pages/organizer_dashboard_page.dart';
import 'package:getagig/features/onboard/presentation/pages/onboard_page.dart';
import 'package:getagig/features/splash/presentation/pages/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  String currentUserRole() {
    final role = ref.read(authViewModelProvider).user?.role.toLowerCase();
    switch (role) {
      case 'admin':
      case 'organizer':
      case 'musician':
        return role!;
      default:
        return 'musician';
    }
  }

  String roleHomePath(String role) {
    switch (role) {
      case 'admin':
        return RouteConstants.adminDashboard;
      case 'organizer':
        return RouteConstants.organizerDashboard;
      default:
        return RouteConstants.musicianDashboard;
    }
  }

  bool isPathWithin(String currentPath, String rootPath) {
    return currentPath == rootPath || currentPath.startsWith('$rootPath/');
  }

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
      final hasSeenOnboarding = ref
          .read(userSessionServiceProvider)
          .hasSeenOnboarding();

      const staticPublicRoutes = [
        RouteConstants.splash,
        RouteConstants.onboarding,
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
        final role = currentUserRole();
        final homePath = roleHomePath(role);

        if (isPublicRoute || currentPath == RouteConstants.dashboard) {
          return homePath;
        }

        final accessingAdmin = isPathWithin(
          currentPath,
          RouteConstants.adminDashboard,
        );
        final accessingOrganizer = isPathWithin(
          currentPath,
          RouteConstants.organizerDashboard,
        );
        final accessingMusician = isPathWithin(
          currentPath,
          RouteConstants.musicianDashboard,
        );

        if (role == 'admin' && (accessingOrganizer || accessingMusician)) {
          return homePath;
        }

        if (role == 'organizer' && (accessingAdmin || accessingMusician)) {
          return homePath;
        }

        if (role == 'musician' && (accessingAdmin || accessingOrganizer)) {
          return homePath;
        }

        return null;
      }

      if (authStatus == AuthStatus.registered &&
          currentPath != RouteConstants.login) {
        return RouteConstants.login;
      }

      if (isPublicRoute) {
        if (currentPath == RouteConstants.splash) {
          return hasSeenOnboarding
              ? RouteConstants.login
              : RouteConstants.onboarding;
        }

        if (currentPath == RouteConstants.onboarding && hasSeenOnboarding) {
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
        path: RouteConstants.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardPage(),
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
        redirect: (context, state) {
          final role = currentUserRole();
          return roleHomePath(role);
        },
      ),
      GoRoute(
        path: RouteConstants.musicianDashboard,
        name: RouteNames.musicianDashboard,
        builder: (context, state) => const MusicianDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.organizerDashboard,
        name: RouteNames.organizerDashboard,
        builder: (context, state) => const OrganizerDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.adminDashboard,
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
  );
});
