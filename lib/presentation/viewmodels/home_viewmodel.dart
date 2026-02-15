import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/search_history_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  HomeViewModel(this._restaurantRepository);

  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  String _query = '';
  String _sortBy = AppConstants.sortOptions.first;
  String _selectedCuisine = 'All';
  bool _highRatingOnly = false;
  String _lastStoredQuery = '';

  List<RestaurantModel> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  String get sortBy => _sortBy;
  String get selectedCuisine => _selectedCuisine;
  bool get highRatingOnly => _highRatingOnly;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _restaurants = await _restaurantRepository.searchRestaurants(
        query: _query,
        selectedCuisine: _selectedCuisine,
        highRatingOnly: _highRatingOnly,
        sortBy: _sortBy,
      );

      final normalizedQuery = _query.trim();
      if (normalizedQuery.isNotEmpty && normalizedQuery.toLowerCase() != _lastStoredQuery.toLowerCase()) {
        await _restaurantRepository.addSearchHistory(
          SearchHistoryModel(
            id: IdGenerator.next('s'),
            userId: userId,
            query: normalizedQuery,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        _lastStoredQuery = normalizedQuery;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuery(String value, String userId) async {
    _query = value.trimLeft();
    await load(userId);
  }

  Future<void> updateCuisine(String value, String userId) async {
    _selectedCuisine = value;
    await load(userId);
  }

  Future<void> updateSort(String value, String userId) async {
    _sortBy = value;
    await load(userId);
  }

  Future<void> toggleHighRating(String userId) async {
    _highRatingOnly = !_highRatingOnly;
    await load(userId);
  }

  Future<void> resetFilters(String userId) async {
    _query = '';
    _sortBy = AppConstants.sortOptions.first;
    _selectedCuisine = 'All';
    _highRatingOnly = false;
    await load(userId);
  }
}
