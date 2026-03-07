import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/search_history_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;
  final LocationService _locationService;

  HomeViewModel(this._restaurantRepository, this._locationService);

  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  String _query = '';
  String _sortBy = AppConstants.sortOptions.first;
  String _selectedCuisine = 'All';
  bool _highRatingOnly = false;
  String _lastStoredQuery = '';
  UserLocation? _userLocation;
  String? _locationError;

  List<RestaurantModel> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  String get sortBy => _sortBy;
  String get selectedCuisine => _selectedCuisine;
  bool get highRatingOnly => _highRatingOnly;
  UserLocation? get userLocation => _userLocation;
  String? get locationError => _locationError;

  Future<void> _ensureUserLocation() async {
    if (_userLocation != null) {
      return;
    }
    try {
      _locationError = null;
      _userLocation = await _locationService.getCurrentLocation();
    } catch (e, st) {
      AppLogger.error(e, st, context: 'HomeViewModel.location');
      _locationError = e.toString();
    }
  }

  Future<void> refreshLocation() async {
    _userLocation = null;
    await _ensureUserLocation();
    notifyListeners();
  }

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      var effectiveSortBy = _sortBy;
      if (_sortBy == 'Nearest') {
        await _ensureUserLocation();
        if (_userLocation == null) {
          effectiveSortBy = 'Top Rated';
        }
      }
      _restaurants = await _restaurantRepository.searchRestaurants(
        query: _query,
        selectedCuisine: _selectedCuisine,
        highRatingOnly: _highRatingOnly,
        sortBy: effectiveSortBy,
        userLatitude: _userLocation?.latitude,
        userLongitude: _userLocation?.longitude,
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
    } catch (e, st) {
      AppLogger.error(e, st, context: 'HomeViewModel.load');
      _error = 'Unable to load restaurants right now.';
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
