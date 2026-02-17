import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/review_model.dart';
import '../../data/models/search_history_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
