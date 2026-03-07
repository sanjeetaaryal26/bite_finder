import 'package:birdle/data/models/feedback_model.dart';
import 'package:birdle/data/models/restaurant_model.dart';
import 'package:birdle/data/models/review_model.dart';
import 'package:birdle/data/models/search_history_model.dart';
import 'package:birdle/domain/repositories/feedback_repository.dart';
import 'package:birdle/domain/repositories/restaurant_repository.dart';

class FakeRestaurantRepository implements RestaurantRepository {
  List<RestaurantModel> restaurants = [];
  List<RestaurantModel> favorites = [];
  List<RestaurantModel> recommendations = [];
  final List<SearchHistoryModel> searchHistory = [];

  bool throwOnGetRestaurants = false;
  bool throwOnGetFavorites = false;
  bool throwOnGetRecommendations = false;

  int getRestaurantsCalls = 0;
  int getFavoritesCalls = 0;
  int getRecommendationsCalls = 0;

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    getRestaurantsCalls += 1;
    if (throwOnGetRestaurants) {
      throw Exception('getRestaurants failed');
    }
    return restaurants;
  }

  @override
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId) async {
    getFavoritesCalls += 1;
    if (throwOnGetFavorites) {
      throw Exception('getFavoriteRestaurants failed');
    }
    return favorites;
  }

  @override
  Future<List<RestaurantModel>> getRecommendations(String userId) async {
    getRecommendationsCalls += 1;
    if (throwOnGetRecommendations) {
      throw Exception('getRecommendations failed');
    }
    return recommendations;
  }

  @override
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? selectedCuisine,
    bool highRatingOnly = false,
    String sortBy = 'Top Rated',
    double? userLatitude,
    double? userLongitude,
  }) async {
    return restaurants;
  }

  @override
  Future<void> addSearchHistory(SearchHistoryModel history) async {
    searchHistory.add(history);
  }

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async {
    for (final restaurant in restaurants) {
      if (restaurant.id == id) {
        return restaurant;
      }
    }
    return null;
  }

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
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async => searchHistory;

  @override
  Future<void> createRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> updateRestaurant(RestaurantModel restaurant) async {}

  @override
  Future<void> deleteRestaurant(String restaurantId) async {}
}

class FakeFeedbackRepository implements FeedbackRepository {
  List<FeedbackModel> userFeedback = [];
  bool throwOnAddFeedback = false;
  bool throwOnGetFeedbackByUser = false;
  int addFeedbackCalls = 0;
  int getFeedbackByUserCalls = 0;
  FeedbackModel? lastAddedFeedback;

  @override
  Future<void> addFeedback(FeedbackModel feedback) async {
    addFeedbackCalls += 1;
    if (throwOnAddFeedback) {
      throw Exception('addFeedback failed');
    }
    lastAddedFeedback = feedback;
    userFeedback = [...userFeedback, feedback];
  }

  @override
  Future<List<FeedbackModel>> getFeedbackByUser(String userId) async {
    getFeedbackByUserCalls += 1;
    if (throwOnGetFeedbackByUser) {
      throw Exception('getFeedbackByUser failed');
    }
    return userFeedback.where((item) => item.userId == userId).toList();
  }

  @override
  Future<List<FeedbackModel>> getAllFeedback() async => userFeedback;

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    userFeedback = userFeedback.where((item) => item.id != feedbackId).toList();
  }
}
