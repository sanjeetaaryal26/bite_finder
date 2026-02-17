import 'package:flutter/material.dart';

import '../../core/utils/id_generator.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/review_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

class RestaurantDetailViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  RestaurantDetailViewModel(this._restaurantRepository);

  RestaurantModel? _restaurant;
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;
  bool _isFavorite = false;

  RestaurantModel? get restaurant => _restaurant;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFavorite => _isFavorite;

  Future<void> load({required String restaurantId, required String userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurant = await _restaurantRepository.getRestaurantById(restaurantId);
      _reviews = await _restaurantRepository.getReviewsByRestaurant(restaurantId);
      _isFavorite = await _restaurantRepository.isFavorite(userId, restaurantId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String userId) async {
    if (_restaurant == null) {
      return;
    }

    if (_isFavorite) {
      await _restaurantRepository.removeFavorite(userId, _restaurant!.id);
      _isFavorite = false;
    } else {
      await _restaurantRepository.addFavorite(userId, _restaurant!.id);
      _isFavorite = true;
    }
    notifyListeners();
  }

  Future<bool> addReview({
    required String userId,
    required int rating,
    required String comment,
  }) async {
    if (_restaurant == null) {
      return false;
    }

    final normalizedComment = comment.trim();
    final normalizedRating = rating.clamp(1, 5);
    if (normalizedComment.length < 5) {
      _error = 'Comment is too short';
      notifyListeners();
      return false;
    }

    try {
      await _restaurantRepository.addReview(
        ReviewModel(
          id: IdGenerator.next('rev'),
          restaurantId: _restaurant!.id,
          userId: userId,
          rating: normalizedRating,
          comment: normalizedComment,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      await load(restaurantId: _restaurant!.id, userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
