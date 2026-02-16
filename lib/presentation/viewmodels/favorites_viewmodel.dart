import 'package:flutter/material.dart';

import '../../data/models/restaurant_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) => load(userId);
}
