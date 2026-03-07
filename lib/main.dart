import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'package:birdle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:birdle/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:birdle/features/restaurant/data/repositories/restaurant_repository_impl.dart';
import 'package:birdle/core/services/local_storage_service.dart';
import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/admin/presentation/view_model/admin_viewmodel.dart';
import 'package:birdle/features/favorites/presentation/view_model/favorites_viewmodel.dart';
import 'package:birdle/features/feedback/presentation/view_model/feedback_viewmodel.dart';
import 'package:birdle/features/home/presentation/view_model/home_viewmodel.dart';
import 'package:birdle/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:birdle/features/recommendations/presentation/view_model/recommendations_viewmodel.dart';
import 'package:birdle/features/restaurant/presentation/view_model/restaurant_detail_viewmodel.dart';
import 'package:birdle/features/theme/presentation/view_model/theme_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(details.exception, details.stack ?? StackTrace.current, context: 'FlutterError');
  };
  ErrorWidget.builder = (details) {
    AppLogger.error(details.exception, StackTrace.current, context: 'ErrorWidget');
    return const SizedBox.shrink();
  };

  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);

  final authRepository = AuthRepositoryImpl(storage);
  final restaurantRepository = RestaurantRepositoryImpl(storage);
  final feedbackRepository = FeedbackRepositoryImpl(storage);
  final locationService = LocationService();

  final authViewModel = AuthViewModel(authRepository);
  await authViewModel.initialize();

  runApp(
    BiteFinderApp(
      authViewModel: authViewModel,
      authRepository: authRepository,
      restaurantRepository: restaurantRepository,
      feedbackRepository: feedbackRepository,
      locationService: locationService,
    ),
  );
}

class BiteFinderApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final AuthRepositoryImpl authRepository;
  final RestaurantRepositoryImpl restaurantRepository;
  final FeedbackRepositoryImpl feedbackRepository;
  final LocationService locationService;

  const BiteFinderApp({
    super.key,
    required this.authViewModel,
    required this.authRepository,
    required this.restaurantRepository,
    required this.feedbackRepository,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(authViewModel);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => AdminViewModel(authRepository, restaurantRepository, feedbackRepository)),
        ChangeNotifierProvider(create: (_) => HomeViewModel(restaurantRepository, locationService)),
        ChangeNotifierProvider(create: (_) => RestaurantDetailViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => RecommendationsViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => FeedbackViewModel(feedbackRepository, restaurantRepository)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme(seedColor: themeVm.seedColor),
            darkTheme: AppTheme.darkTheme(seedColor: themeVm.seedColor),
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
