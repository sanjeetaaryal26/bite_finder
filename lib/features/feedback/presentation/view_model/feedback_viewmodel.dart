import 'package:flutter/material.dart';

import 'package:birdle/core/utils/app_logger.dart';
import 'package:birdle/core/utils/id_generator.dart';
import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:birdle/features/restaurant/domain/repositories/restaurant_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _feedbackRepository;
  final RestaurantRepository _restaurantRepository;

  FeedbackViewModel(this._feedbackRepository, this._restaurantRepository);

  bool _isLoading = false;
  String? _error;
  List<FeedbackModel> _submissions = [];
  List<RestaurantModel> _restaurants = [];
  List<ReviewModel> _reviews = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedbackModel> get submissions => _submissions;
  List<RestaurantModel> get restaurants => _restaurants;
  List<ReviewModel> get reviews => _reviews;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      try {
        _restaurants = await _restaurantRepository.getRestaurants();
      } catch (e, st) {
        AppLogger.error(e, st, context: 'FeedbackViewModel.load.restaurants');
      }

      _submissions = await _feedbackRepository.getFeedbackByUser(userId);
      _reviews = await _restaurantRepository.getReviewsByUser(userId);
      _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, st) {
      AppLogger.error(e, st, context: 'FeedbackViewModel.load');
      _error = 'Unable to load feedback submissions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submit({
    required String userId,
    String? restaurantId,
    required FeedbackType type,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalizedMessage = message.trim();
      final feedback = FeedbackModel(
        id: IdGenerator.next('fb'),
        userId: userId,
        restaurantId: restaurantId,
        type: type,
        message: normalizedMessage,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _feedbackRepository.addFeedback(
        feedback,
      );

      try {
        _submissions = await _feedbackRepository.getFeedbackByUser(userId);
      } catch (e, st) {
        AppLogger.error(e, st, context: 'FeedbackViewModel.submit.refresh');
        _submissions = [
          feedback,
          ..._submissions.where((item) => item.id != feedback.id),
        ];
      }

      _submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'FeedbackViewModel.submit');
      _error = 'Unable to submit feedback. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
