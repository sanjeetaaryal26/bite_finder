import 'package:flutter/material.dart';

import 'package:birdle/core/constants/app_constants.dart';
import 'package:birdle/core/utils/app_logger.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/search/data/models/search_history_model.dart';
import 'package:birdle/features/restaurant/domain/repositories/restaurant_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  ProfileViewModel(this._restaurantRepository);

  bool _isLoading = false;
  String? _error;
  List<SearchHistoryModel> _recentSearches = [];
  List<ReviewModel> _reviews = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SearchHistoryModel> get recentSearches => _recentSearches;
  List<ReviewModel> get reviews => _reviews;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recentSearches = (await _restaurantRepository.getSearchHistory(userId)).take(AppConstants.maxProfileItems).toList();
      _reviews = (await _restaurantRepository.getReviewsByUser(userId)).take(AppConstants.maxProfileItems).toList();
    } catch (e, st) {
      AppLogger.error(e, st, context: 'ProfileViewModel.load');
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
