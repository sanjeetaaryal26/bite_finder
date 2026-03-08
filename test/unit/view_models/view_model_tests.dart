import 'package:birdle/core/services/location_service.dart';
import 'package:birdle/features/favorites/presentation/view_model/favorites_viewmodel.dart';
import 'package:birdle/features/home/presentation/view_model/home_viewmodel.dart';
import 'package:birdle/features/recommendations/presentation/view_model/recommendations_viewmodel.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/search/data/models/search_history_model.dart';
import 'package:birdle/features/theme/presentation/view_model/theme_viewmodel.dart';
import 'package:birdle/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRestaurantRepository implements RestaurantRepository {
  List<RestaurantModel> restaurants = [];
  List<RestaurantModel> favorites = [];
  List<RestaurantModel> recommendations = [];

  bool throwOnSearch = false;
  bool throwOnFavorites = false;
  bool throwOnRecommendations = false;

  int searchCalls = 0;
  int favoritesCalls = 0;
  int recommendationsCalls = 0;

  String? lastQuery;
  String? lastCuisine;
  bool? lastHighRatingOnly;

  @override
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? selectedCuisine,
    bool highRatingOnly = false,
    String sortBy = 'Top Rated',
    double? userLatitude,
    double? userLongitude,
  }) async {
    searchCalls += 1;
    lastQuery = query;
    lastCuisine = selectedCuisine;
    lastHighRatingOnly = highRatingOnly;
    if (throwOnSearch) throw Exception('search failed');
    return restaurants;
  }

  @override
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId) async {
    favoritesCalls += 1;
    if (throwOnFavorites) throw Exception('favorites failed');
    return favorites;
  }

  @override
  Future<List<RestaurantModel>> getRecommendations(String userId) async {
    recommendationsCalls += 1;
    if (throwOnRecommendations) throw Exception('recommendations failed');
    return recommendations;
  }

  @override
  Future<void> addSearchHistory(SearchHistoryModel history) async {}

  @override
  Future<List<RestaurantModel>> getRestaurants() async => restaurants;

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async => null;

  @override
  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId) async => [];

  @override
  Future<List<ReviewModel>> getReviewsByUser(String userId) async => [];

  @override
  Future<List<ReviewModel>> getAllReviews() async => [];

  @override
  Future<void> addReview(ReviewModel review) async {}

  @override
  Future<void> deleteReview(String reviewId) async {}

  @override
  Future<void> addFavorite(String userId, String restaurantId) async {}

  @override
  Future<void> removeFavorite(String userId, String restaurantId) async {}

  @override
  Future<bool> isFavorite(String userId, String restaurantId) async => false;

  @override
  Future<List<String>> getFavoriteRestaurantIds(String userId) async => [];

  @override
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async => [];

  @override
  Future<void> createRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> updateRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> deleteRestaurant(String restaurantId) async {}
}

class _LocationOk extends LocationService {
  @override
  Future<UserLocation> getCurrentLocation() async =>
      const UserLocation(latitude: 27.7, longitude: 85.3);
}

class _LocationFail extends LocationService {
  @override
  Future<UserLocation> getCurrentLocation() async {
    throw const LocationServiceException('Location permission denied.');
  }
}

RestaurantModel _restaurant(String id) {
  return RestaurantModel(
    id: id,
    name: 'Restaurant $id',
    cuisines: const ['Nepali'],
    location: 'Kathmandu',
    description: 'desc',
    specialties: const ['Momo'],
    services: const ['Dine-in'],
    ratingAvg: 4.3,
    ratingCount: 50,
    priceRange: '\$',
    photos: const [],
    bestSellers: const ['Steam Momo'],
    latitude: 27.7,
    longitude: 85.3,
  );
}

void main() {
  group('ViewModels: HomeViewModel', () {
    test('load fetches restaurants and clears loading state', () async {
      final repo = _FakeRestaurantRepository()..restaurants = [_restaurant('1'), _restaurant('2')];
      final vm = HomeViewModel(repo, _LocationOk());

      await vm.load('u1');

      expect(vm.isLoading, false);
      expect(vm.restaurants.length, 2);
      expect(repo.searchCalls, 1);
    });

    test('updateQuery trims left spaces and triggers load', () async {
      final repo = _FakeRestaurantRepository()..restaurants = [_restaurant('1')];
      final vm = HomeViewModel(repo, _LocationOk());

      await vm.updateQuery('   momo', 'u1');

      expect(vm.query, 'momo');
      expect(repo.lastQuery, 'momo');
    });

    test('toggleHighRating flips flag and reloads', () async {
      final repo = _FakeRestaurantRepository()..restaurants = [_restaurant('1')];
      final vm = HomeViewModel(repo, _LocationOk());

      await vm.toggleHighRating('u1');

      expect(vm.highRatingOnly, true);
      expect(repo.lastHighRatingOnly, true);
    });

    test('nearest sort sets locationError when location fails', () async {
      final repo = _FakeRestaurantRepository()..restaurants = [_restaurant('1')];
      final vm = HomeViewModel(repo, _LocationFail());

      await vm.updateSort('Nearest', 'u1');

      expect(vm.locationError, contains('Location permission denied'));
      expect(vm.isLoading, false);
    });
  });

  group('ViewModels: FavoritesViewModel', () {
    test('load populates favorites list', () async {
      final repo = _FakeRestaurantRepository()..favorites = [_restaurant('a')];
      final vm = FavoritesViewModel(repo);

      await vm.load('u1');

      expect(vm.favorites.length, 1);
      expect(repo.favoritesCalls, 1);
    });

    test('load handles repository exception gracefully', () async {
      final repo = _FakeRestaurantRepository()..throwOnFavorites = true;
      final vm = FavoritesViewModel(repo);

      await vm.load('u1');

      expect(vm.favorites, isEmpty);
      expect(vm.error, isNull);
      expect(vm.isLoading, false);
    });
  });

  group('ViewModels: RecommendationsViewModel', () {
    test('load populates recommendations', () async {
      final repo = _FakeRestaurantRepository()..recommendations = [_restaurant('x'), _restaurant('y')];
      final vm = RecommendationsViewModel(repo);

      await vm.load('u1');

      expect(vm.recommendations.length, 2);
      expect(repo.recommendationsCalls, 1);
    });

    test('refresh calls load and re-fetches data', () async {
      final repo = _FakeRestaurantRepository()..recommendations = [_restaurant('x')];
      final vm = RecommendationsViewModel(repo);

      await vm.refresh('u1');
      await vm.refresh('u1');

      expect(repo.recommendationsCalls, 2);
    });
  });

  group('ViewModels: ThemeViewModel', () {
    test('applyCuisine updates activeCuisine and seedColor', () {
      final vm = ThemeViewModel();

      vm.applyCuisine('Nepali');

      expect(vm.activeCuisine, 'Nepali');
      expect(vm.seedColor, ThemeViewModel.colorForCuisine('Nepali'));
    });

    test('reset returns theme to All cuisine', () {
      final vm = ThemeViewModel();
      vm.applyCuisine('Thai');

      vm.reset();

      expect(vm.activeCuisine, 'All');
      expect(vm.seedColor, ThemeViewModel.colorForCuisine('All'));
    });
  });
}
