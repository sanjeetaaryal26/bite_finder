import '../../data/models/restaurant_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/search_history_model.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantModel>> getRestaurants();
  Future<RestaurantModel?> getRestaurantById(String id);

  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? selectedCuisine,
    bool highRatingOnly,
    String sortBy,
  });

  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId);
  Future<List<ReviewModel>> getReviewsByUser(String userId);

  Future<void> addReview(ReviewModel review);

  Future<void> addFavorite(String userId, String restaurantId);
  Future<void> removeFavorite(String userId, String restaurantId);
  Future<bool> isFavorite(String userId, String restaurantId);
  Future<List<String>> getFavoriteRestaurantIds(String userId);
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId);

  Future<void> addSearchHistory(SearchHistoryModel history);
  Future<List<SearchHistoryModel>> getSearchHistory(String userId);

  Future<List<RestaurantModel>> getRecommendations(String userId);
}
