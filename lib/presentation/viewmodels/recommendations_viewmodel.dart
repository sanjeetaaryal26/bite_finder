import 'package:flutter/material.dart';

import '../../data/models/restaurant_model.dart';
import '../../domain/repositories/restaurant_repository.dart';

class RecommendationsViewModel extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  RecommendationsViewModel(this._restaurantRepository);

  List<RestaurantModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<RestaurantModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _restaurantRepository.getRecommendations(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) => load(userId);
}
