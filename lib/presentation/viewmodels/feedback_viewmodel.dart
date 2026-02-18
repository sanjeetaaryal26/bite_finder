import 'package:flutter/material.dart';

import '../../core/utils/id_generator.dart';
import '../../data/models/feedback_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/repositories/restaurant_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _feedbackRepository;
  final RestaurantRepository _restaurantRepository;

  FeedbackViewModel(this._feedbackRepository, this._restaurantRepository);

  bool _isLoading = false;
  String? _error;
  List<FeedbackModel> _submissions = [];
  List<RestaurantModel> _restaurants = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedbackModel> get submissions => _submissions;
  List<RestaurantModel> get restaurants => _restaurants;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantRepository.getRestaurants();
      _submissions = await _feedbackRepository.getFeedbackByUser(userId);
    } catch (e) {
      _error = e.toString();
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
      await _feedbackRepository.addFeedback(
        FeedbackModel(
          id: IdGenerator.next('fb'),
          userId: userId,
          restaurantId: restaurantId,
          type: type,
          message: normalizedMessage,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      _submissions = await _feedbackRepository.getFeedbackByUser(userId);
      _submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
