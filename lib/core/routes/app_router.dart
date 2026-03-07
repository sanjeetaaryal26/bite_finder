import 'package:go_router/go_router.dart';

import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/auth/presentation/screens/auth_landing_screen.dart';
import 'package:birdle/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:birdle/features/auth/presentation/screens/login_screen.dart';
import 'package:birdle/features/auth/presentation/screens/register_screen.dart';
import 'package:birdle/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:birdle/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:birdle/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:birdle/features/home/presentation/screens/home_screen.dart';
import 'package:birdle/features/profile/presentation/screens/profile_screen.dart';
import 'package:birdle/features/recommendations/presentation/screens/recommendations_screen.dart';
import 'package:birdle/features/restaurant/presentation/screens/restaurant_detail_screen.dart';
import 'package:birdle/features/restaurant/presentation/screens/restaurant_map_screen.dart';
import 'package:birdle/features/splash/presentation/screens/splash_screen.dart';
import 'package:birdle/core/widgets/app_scaffold.dart';
import 'package:birdle/features/auth/presentation/screens/fingerprint_login.dart';

GoRouter buildRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final isLoggedIn = authViewModel.isLoggedIn;
      final isAdmin = authViewModel.isAdmin;
      final location = state.matchedLocation;
      final fingerprintUserId = authViewModel.fingerprintEnabledUserId;

      final isAuthRoute = location == '/auth' ||
          location == '/login' ||
          location == '/register' ||
          location == '/forgot-password' ||
          location == '/splash' ||
          location == '/fingerprint-login';

      if (!authViewModel.initialized) {
        return location == '/splash' ? null : '/splash';
      }

      final disallowedExplicitAuthRoutes = [
        '/login',
        '/register',
        '/forgot-password'
      ];
      // If fingerprint login is enabled for a user, require the fingerprint
      // unlock screen until the app records a successful biometric unlock.
      if (fingerprintUserId != null &&
          !authViewModel.fingerprintUnlocked &&
          location != '/fingerprint-login') {
        return '/fingerprint-login';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/auth';
      }

      final isAdminRoute = location == '/admin';
      if (isAdminRoute && !isAdmin) {
        return '/home';
      }

      if (isLoggedIn &&
          (location == '/auth' ||
              location == '/login' ||
              location == '/register' ||
              location == '/forgot-password')) {
        return isAdmin ? '/admin' : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/fingerprint-login',
        builder: (context, state) => const FingerprintLogin(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthLandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recommendations',
                pageBuilder: (context, state) => const NoTransitionPage(child: RecommendationsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feedback',
                pageBuilder: (context, state) => const NoTransitionPage(child: FeedbackScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) => RestaurantDetailScreen(
          restaurantId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/restaurant/:id/map',
        builder: (context, state) => RestaurantMapScreen(
          restaurant: state.extra is RestaurantModel
              ? state.extra as RestaurantModel
              : null,
        ),
      ),
    ],
  );
}
