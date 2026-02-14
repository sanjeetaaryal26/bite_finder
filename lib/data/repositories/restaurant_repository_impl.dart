import '../../core/utils/restaurant_filter.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../models/favorite_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../models/search_history_model.dart';
import '../sources/local_storage_service.dart';
import '../sources/mock_restaurant_data.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final LocalStorageService storage;

  RestaurantRepositoryImpl(this.storage);

  List<RestaurantModel> _withDynamicRatings(List<RestaurantModel> base, List<ReviewModel> reviews) {
    return base.map((restaurant) {
      final restaurantReviews = reviews.where((r) => r.restaurantId == restaurant.id).toList();
      if (restaurantReviews.isEmpty) {
        return restaurant;
      }

      final totalFromBase = restaurant.ratingAvg * restaurant.ratingCount;
      final totalFromReviews = restaurantReviews.fold<double>(0, (sum, r) => sum + r.rating);
      final newCount = restaurant.ratingCount + restaurantReviews.length;
      final newAvg = (totalFromBase + totalFromReviews) / newCount;

      return restaurant.copyWith(
        ratingAvg: double.parse(newAvg.toStringAsFixed(1)),
        ratingCount: newCount,
      );
    }).toList();
  }

  List<ReviewModel> _allReviews() => storage.readReviews().map(ReviewModel.fromJson).toList();

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    final base = MockRestaurantData.restaurants;
    final reviews = _allReviews();
    return _withDynamicRatings(base, reviews);
  }

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async {
    final restaurants = await getRestaurants();
    final matches = restaurants.where((r) => r.id == id).toList();
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }

  @override
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? selectedCuisine,
    bool highRatingOnly = false,
    String sortBy = 'Top Rated',
  }) async {
    final restaurants = await getRestaurants();
    return RestaurantFilter.apply(
      restaurants: restaurants,
      query: query,
      selectedCuisine: selectedCuisine,
      highRatingOnly: highRatingOnly,
      sortBy: sortBy,
    );
  }

  @override
  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId) async {
    final reviews = _allReviews().where((r) => r.restaurantId == restaurantId).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    final reviews = _allReviews();
    reviews.add(review);
    await storage.writeReviews(reviews.map((r) => r.toJson()).toList());
  }

  List<FavoriteModel> _favorites() => storage.readFavorites().map(FavoriteModel.fromJson).toList();

  @override
  Future<void> addFavorite(String userId, String restaurantId) async {
    final favorites = _favorites();
    final exists = favorites.any((f) => f.userId == userId && f.restaurantId == restaurantId);
    if (!exists) {
      favorites.add(FavoriteModel(userId: userId, restaurantId: restaurantId));
      await storage.writeFavorites(favorites.map((f) => f.toJson()).toList());
    }
  }

  @override
  Future<void> removeFavorite(String userId, String restaurantId) async {
    final favorites = _favorites();
    favorites.removeWhere((f) => f.userId == userId && f.restaurantId == restaurantId);
    await storage.writeFavorites(favorites.map((f) => f.toJson()).toList());
  }

  @override
  Future<bool> isFavorite(String userId, String restaurantId) async {
    final favorites = _favorites();
    return favorites.any((f) => f.userId == userId && f.restaurantId == restaurantId);
  }

  @override
  Future<List<String>> getFavoriteRestaurantIds(String userId) async {
    return _favorites().where((f) => f.userId == userId).map((f) => f.restaurantId).toList();
  }

  @override
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId) async {
    final ids = await getFavoriteRestaurantIds(userId);
    final restaurants = await getRestaurants();
    final favorites = restaurants.where((r) => ids.contains(r.id)).toList();
    favorites.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    return favorites;
  }

  @override
  Future<void> addSearchHistory(SearchHistoryModel history) async {
    final entries = storage.readSearchHistory().map(SearchHistoryModel.fromJson).toList();
    entries.add(history);
    await storage.writeSearchHistory(entries.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async {
    final entries = storage.readSearchHistory().map(SearchHistoryModel.fromJson).where((e) => e.userId == userId).toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<List<RestaurantModel>> getRecommendations(String userId) async {
    final restaurants = await getRestaurants();
    final favoriteIds = await getFavoriteRestaurantIds(userId);
    final favorites = restaurants.where((r) => favoriteIds.contains(r.id)).toList();
    final histories = await getSearchHistory(userId);

    final cuisinePreference = <String, int>{};
    for (final favorite in favorites) {
      for (final cuisine in favorite.cuisines) {
        cuisinePreference[cuisine] = (cuisinePreference[cuisine] ?? 0) + 2;
      }
    }

    final queries = histories.take(10).map((h) => h.query.toLowerCase()).toList();

    if (cuisinePreference.isEmpty && queries.isEmpty) {
      final fallback = [...restaurants];
      fallback.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      return fallback.take(8).toList();
    }

    final scored = restaurants.map((restaurant) {
      double score = restaurant.ratingAvg;

      for (final cuisine in restaurant.cuisines) {
        score += (cuisinePreference[cuisine] ?? 0).toDouble();
      }

      for (final q in queries) {
        if (q.trim().isEmpty) {
          continue;
        }
        final match = restaurant.name.toLowerCase().contains(q) ||
            restaurant.cuisines.any((c) => c.toLowerCase().contains(q)) ||
            restaurant.specialties.any((s) => s.toLowerCase().contains(q));
        if (match) {
          score += 1.5;
        }
      }

      if (favoriteIds.contains(restaurant.id)) {
        score += 2;
      }

      return (restaurant: restaurant, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.restaurant).take(8).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final reviews = _allReviews().where((r) => r.userId == userId).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}
