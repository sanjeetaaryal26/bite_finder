import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _usersKey = 'users';
  static const _sessionUserIdKey = 'session_user_id';
  static const _reviewsKey = 'reviews';
  static const _favoritesKey = 'favorites';
  static const _feedbackKey = 'feedback';
  static const _searchHistoryKey = 'search_history';
  static const _adminRestaurantsKey = 'admin_restaurants';
  static const _adminUpdatedRestaurantsKey = 'admin_updated_restaurants';
  static const _deletedRestaurantIdsKey = 'deleted_restaurant_ids';

  final SharedPreferences prefs;

  LocalStorageService(this.prefs);

  List<Map<String, dynamic>> readList(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>> readUsers() => readList(_usersKey);
  Future<void> writeUsers(List<Map<String, dynamic>> value) => writeList(_usersKey, value);

  List<Map<String, dynamic>> readReviews() => readList(_reviewsKey);
  Future<void> writeReviews(List<Map<String, dynamic>> value) => writeList(_reviewsKey, value);

  List<Map<String, dynamic>> readFavorites() => readList(_favoritesKey);
  Future<void> writeFavorites(List<Map<String, dynamic>> value) => writeList(_favoritesKey, value);

  List<Map<String, dynamic>> readFeedback() => readList(_feedbackKey);
  Future<void> writeFeedback(List<Map<String, dynamic>> value) => writeList(_feedbackKey, value);

  List<Map<String, dynamic>> readSearchHistory() => readList(_searchHistoryKey);
  Future<void> writeSearchHistory(List<Map<String, dynamic>> value) => writeList(_searchHistoryKey, value);

  List<Map<String, dynamic>> readAdminRestaurants() => readList(_adminRestaurantsKey);
  Future<void> writeAdminRestaurants(List<Map<String, dynamic>> value) => writeList(_adminRestaurantsKey, value);

  List<Map<String, dynamic>> readAdminUpdatedRestaurants() => readList(_adminUpdatedRestaurantsKey);
  Future<void> writeAdminUpdatedRestaurants(List<Map<String, dynamic>> value) => writeList(_adminUpdatedRestaurantsKey, value);

  List<String> readDeletedRestaurantIds() {
    final raw = prefs.getStringList(_deletedRestaurantIdsKey);
    return raw ?? [];
  }

  Future<void> writeDeletedRestaurantIds(List<String> ids) => prefs.setStringList(_deletedRestaurantIdsKey, ids);

  String? readSessionUserId() => prefs.getString(_sessionUserIdKey);
  Future<void> writeSessionUserId(String userId) => prefs.setString(_sessionUserIdKey, userId);
  Future<void> clearSessionUserId() => prefs.remove(_sessionUserIdKey);
}
