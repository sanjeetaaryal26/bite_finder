import 'package:birdle/core/services/location_service.dart';
import 'package:birdle/data/models/restaurant_model.dart';
import 'package:birdle/data/models/review_model.dart';
import 'package:birdle/data/models/search_history_model.dart';
import 'package:birdle/data/sources/mock_restaurant_data.dart';
import 'package:birdle/domain/repositories/restaurant_repository.dart';
import 'package:birdle/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRestaurantRepository implements RestaurantRepository {
  List<RestaurantModel> restaurantsToReturn;
  bool throwOnSearch = false;
  String? lastSortBy;
  double? lastUserLatitude;
  double? lastUserLongitude;
  int addSearchHistoryCalls = 0;
  final List<String> storedQueries = [];

  _FakeRestaurantRepository({required this.restaurantsToReturn});

  @override
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? selectedCuisine,
    bool highRatingOnly = false,
    String sortBy = 'Top Rated',
    double? userLatitude,
    double? userLongitude,
  }) async {
    if (throwOnSearch) {
      throw Exception('search failed');
    }
    lastSortBy = sortBy;
    lastUserLatitude = userLatitude;
    lastUserLongitude = userLongitude;
    return restaurantsToReturn;
  }

  @override
  Future<void> addSearchHistory(SearchHistoryModel history) async {
    addSearchHistoryCalls += 1;
    storedQueries.add(history.query);
  }

  @override
  Future<List<RestaurantModel>> getRestaurants() async => restaurantsToReturn;

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
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId) async => [];

  @override
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async => [];

  @override
  Future<List<RestaurantModel>> getRecommendations(String userId) async => [];

  @override
  Future<void> createRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> updateRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> deleteRestaurant(String restaurantId) async {}
}

class _SuccessfulLocationService extends LocationService {
  final UserLocation location;

  _SuccessfulLocationService(this.location);

  @override
  Future<UserLocation> getCurrentLocation() async => location;
}

class _FailingLocationService extends LocationService {
  @override
  Future<UserLocation> getCurrentLocation() async {
    throw const LocationServiceException('Location permission denied.');
  }
}

void main() {
  group('HomeViewModel', () {
    test('uses nearest sort and location coordinates when location is available', () async {
      final repo = _FakeRestaurantRepository(restaurantsToReturn: MockRestaurantData.restaurants);
      final vm = HomeViewModel(
        repo,
        _SuccessfulLocationService(const UserLocation(latitude: 27.7172, longitude: 85.3240)),
      );

      await vm.updateSort('Nearest', 'u1');

      expect(repo.lastSortBy, 'Nearest');
      expect(repo.lastUserLatitude, 27.7172);
      expect(repo.lastUserLongitude, 85.3240);
      expect(vm.locationError, isNull);
    });

    test('falls back to top rated when nearest is selected but location fails', () async {
      final repo = _FakeRestaurantRepository(restaurantsToReturn: MockRestaurantData.restaurants);
      final vm = HomeViewModel(repo, _FailingLocationService());

      await vm.updateSort('Nearest', 'u1');

      expect(repo.lastSortBy, 'Top Rated');
      expect(repo.lastUserLatitude, isNull);
      expect(repo.lastUserLongitude, isNull);
      expect(vm.locationError, contains('Location permission denied'));
    });

    test('stores search history once per unique normalized query', () async {
      final repo = _FakeRestaurantRepository(restaurantsToReturn: MockRestaurantData.restaurants);
      final vm = HomeViewModel(
        repo,
        _SuccessfulLocationService(const UserLocation(latitude: 27.7172, longitude: 85.3240)),
      );

      await vm.updateQuery('  momo', 'u1');
      await vm.updateQuery('MOMO', 'u1');
      await vm.updateQuery('momo shop', 'u1');

      expect(repo.addSearchHistoryCalls, 2);
      expect(repo.storedQueries, ['momo', 'momo shop']);
    });

    test('sets generic error when repository search throws', () async {
      final repo = _FakeRestaurantRepository(restaurantsToReturn: MockRestaurantData.restaurants)..throwOnSearch = true;
      final vm = HomeViewModel(
        repo,
        _SuccessfulLocationService(const UserLocation(latitude: 27.7172, longitude: 85.3240)),
      );

      await vm.load('u1');

      expect(vm.error, 'Unable to load restaurants right now.');
      expect(vm.isLoading, false);
    });
  });
}
