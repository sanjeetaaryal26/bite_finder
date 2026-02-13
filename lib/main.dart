import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/feedback_repository_impl.dart';
import 'data/repositories/restaurant_repository_impl.dart';
import 'data/sources/local_storage_service.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/favorites_viewmodel.dart';
import 'presentation/viewmodels/feedback_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/recommendations_viewmodel.dart';
import 'presentation/viewmodels/restaurant_detail_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);

  final authRepository = AuthRepositoryImpl(storage);
  final restaurantRepository = RestaurantRepositoryImpl(storage);
  final feedbackRepository = FeedbackRepositoryImpl(storage);

  final authViewModel = AuthViewModel(authRepository);
  await authViewModel.initialize();

  runApp(
    BiteFinderApp(
      authViewModel: authViewModel,
      restaurantRepository: restaurantRepository,
      feedbackRepository: feedbackRepository,
    ),
  );
}

class BiteFinderApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final RestaurantRepositoryImpl restaurantRepository;
  final FeedbackRepositoryImpl feedbackRepository;

  const BiteFinderApp({
    super.key,
    required this.authViewModel,
    required this.restaurantRepository,
    required this.feedbackRepository,
  });

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(authViewModel);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => HomeViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => RestaurantDetailViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => RecommendationsViewModel(restaurantRepository)),
        ChangeNotifierProvider(create: (_) => FeedbackViewModel(feedbackRepository, restaurantRepository)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(restaurantRepository)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
