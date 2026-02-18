import 'package:birdle/core/utils/restaurant_filter.dart';
import 'package:birdle/core/constants/app_constants.dart';
import 'package:birdle/data/sources/mock_restaurant_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Restaurant search filter', () {
    test('should match by cuisine and apply high rating filter', () {
      final result = RestaurantFilter.apply(
        restaurants: MockRestaurantData.restaurants,
        query: 'nepali',
        selectedCuisine: 'All',
        highRatingOnly: true,
        sortBy: 'Top Rated',
      );

      expect(result, isNotEmpty);
      expect(result.every((r) => r.ratingAvg >= AppConstants.highRatingThreshold), true);
      expect(result.any((r) => r.cuisines.map((c) => c.toLowerCase()).contains('nepali')), true);
    });

    test('should sort nearest first when sortBy Nearest', () {
      final result = RestaurantFilter.apply(
        restaurants: MockRestaurantData.restaurants,
        query: '',
        selectedCuisine: 'All',
        highRatingOnly: false,
        sortBy: 'Nearest',
      );

      expect(result.length, greaterThan(2));
      expect(result.first.mockDistanceKm <= result[1].mockDistanceKm, true);
    });

    test('nearest sorting should be deterministic for equal distance entries', () {
      final nearest = RestaurantFilter.apply(
        restaurants: MockRestaurantData.restaurants,
        query: '',
        selectedCuisine: 'All',
        highRatingOnly: false,
        sortBy: 'Nearest',
      );

      final duplicateDistance = nearest
          .where((r) => r.mockDistanceKm == nearest.first.mockDistanceKm)
          .map((r) => r.name)
          .toList();

      final sortedByName = [...duplicateDistance]..sort();
      expect(duplicateDistance, sortedByName);
    });
  });
}
