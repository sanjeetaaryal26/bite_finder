import 'package:go_router/go_router.dart';

import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/views/auth/login_screen.dart';
import '../../presentation/views/auth/register_screen.dart';
import '../../presentation/views/favorites/favorites_screen.dart';
import '../../presentation/views/feedback/feedback_screen.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/profile/profile_screen.dart';
import '../../presentation/views/recommendations/recommendations_screen.dart';
import '../../presentation/views/restaurant/restaurant_detail_screen.dart';
import '../../presentation/views/splash/splash_screen.dart';
import '../../presentation/widgets/app_scaffold.dart';

GoRouter buildRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final isLoggedIn = authViewModel.isLoggedIn;
      final location = state.matchedLocation;

      final isAuthRoute = location == '/login' || location == '/register' || location == '/splash';

      if (!authViewModel.initialized) {
        return location == '/splash' ? null : '/splash';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && (location == '/login' || location == '/register')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesScreen()),
          ),
          GoRoute(
            path: '/recommendations',
            pageBuilder: (context, state) => const NoTransitionPage(child: RecommendationsScreen()),
          ),
          GoRoute(
            path: '/feedback',
            pageBuilder: (context, state) => const NoTransitionPage(child: FeedbackScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) => RestaurantDetailScreen(
          restaurantId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
