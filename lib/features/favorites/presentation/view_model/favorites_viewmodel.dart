import 'package:flutter/material.dart';

import 'package:birdle/core/utils/app_logger.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/domain/repositories/restaurant_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  FavoritesViewModel(this._restaurantRepository);

  List<RestaurantModel> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<RestaurantModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _favorites = await _restaurantRepository.getFavoriteRestaurants(userId);
    } catch (e, st) {
      AppLogger.error(e, st, context: 'FavoritesViewModel.load');
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) => load(userId);
}
