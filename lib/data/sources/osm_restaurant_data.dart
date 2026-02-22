import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/restaurant_model.dart';
import 'mock_restaurant_data.dart';

class OsmRestaurantData {
  static const _assetPath = 'data/osm/kathmandu_restaurants.json';
  static List<RestaurantModel>? _cache;

  static int _stableHash(String value) {
    var hash = 0;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }

  static RestaurantModel _withSeedRating(RestaurantModel restaurant) {
    if (restaurant.ratingCount > 0) {
      return restaurant;
    }
    final seed = _stableHash(restaurant.id);
    final rating = 3.4 + ((seed % 16) / 10.0); // 3.4 - 4.9
    final count = 20 + ((seed ~/ 17) % 380); // 20 - 399
    return restaurant.copyWith(
      ratingAvg: double.parse(rating.toStringAsFixed(1)),
      ratingCount: count,
    );
  }

  static Future<List<RestaurantModel>> restaurants() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cache = decoded
          .map((item) => RestaurantModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .map(_withSeedRating)
          .toList();
      return _cache!;
    } catch (_) {
      _cache = MockRestaurantData.restaurants;
      return _cache!;
    }
  }
}
