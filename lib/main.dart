import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/feedback_repository_impl.dart';
import 'data/repositories/restaurant_repository_impl.dart';
import 'data/sources/local_storage_service.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/admin_viewmodel.dart';
import 'presentation/viewmodels/favorites_viewmodel.dart';
import 'presentation/viewmodels/feedback_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/recommendations_viewmodel.dart';
import 'presentation/viewmodels/restaurant_detail_viewmodel.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

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
