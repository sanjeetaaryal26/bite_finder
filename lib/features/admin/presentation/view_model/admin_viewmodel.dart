import 'package:flutter/material.dart';

import 'package:birdle/core/utils/app_logger.dart';
import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/auth/data/models/user_model.dart';
import 'package:birdle/features/auth/domain/repositories/auth_repository.dart';
import 'package:birdle/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:birdle/features/restaurant/domain/repositories/restaurant_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final RestaurantRepository _restaurantRepository;
  final FeedbackRepository _feedbackRepository;

  AdminViewModel(this._authRepository, this._restaurantRepository, this._feedbackRepository);

  bool _isLoading = false;
  String? _error;

  List<RestaurantModel> _restaurants = [];
  List<UserModel> _users = [];
  List<FeedbackModel> _feedback = [];
  List<ReviewModel> _reviews = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RestaurantModel> get restaurants => _restaurants;
  List<UserModel> get users => _users;
  List<FeedbackModel> get feedback => _feedback;
  List<ReviewModel> get reviews => _reviews;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantRepository.getRestaurants();
      _users = await _authRepository.getUsers();
      _feedback = await _feedbackRepository.getAllFeedback();
      _reviews = await _restaurantRepository.getAllReviews();
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.loadAll');
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRestaurant(RestaurantModel restaurant) async {
    try {
      await _restaurantRepository.createRestaurant(restaurant);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.createRestaurant');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await _restaurantRepository.updateRestaurant(restaurant);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.updateRestaurant');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _restaurantRepository.deleteRestaurant(restaurantId);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.deleteRestaurant');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setUserRole({required String userId, required UserRole role}) async {
    try {
      await _authRepository.updateUserRole(userId: userId, role: role);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.setUserRole');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _authRepository.deleteUser(userId);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.deleteUser');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      await _feedbackRepository.deleteFeedback(feedbackId);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.deleteFeedback');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _restaurantRepository.deleteReview(reviewId);
      await loadAll();
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AdminViewModel.deleteReview');
      _error = null;
      notifyListeners();
      return false;
    }
  }

  UserModel? userById(String userId) {
    final matches = _users.where((u) => u.id == userId).toList();
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }

  RestaurantModel? restaurantById(String restaurantId) {
    final matches = _restaurants.where((r) => r.id == restaurantId).toList();
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }
}
