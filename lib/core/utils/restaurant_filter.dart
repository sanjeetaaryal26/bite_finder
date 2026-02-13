import '../../data/models/restaurant_model.dart';
import '../constants/app_constants.dart';

class RestaurantFilter {
  static List<RestaurantModel> apply({
    required List<RestaurantModel> restaurants,
    required String query,
    String? selectedCuisine,
    required bool highRatingOnly,
    required String sortBy,
  }) {
    var filtered = restaurants.where((restaurant) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          restaurant.name.toLowerCase().contains(q) ||
          restaurant.cuisines.any((c) => c.toLowerCase().contains(q)) ||
          restaurant.specialties.any((s) => s.toLowerCase().contains(q)) ||
          restaurant.bestSellers.any((item) => item.toLowerCase().contains(q));

      final matchesCuisine = selectedCuisine == null || selectedCuisine == 'All'
          ? true
          : restaurant.cuisines.any((c) => c.toLowerCase() == selectedCuisine.toLowerCase());

      final matchesRating = !highRatingOnly || restaurant.ratingAvg >= AppConstants.highRatingThreshold;

      return matchesQuery && matchesCuisine && matchesRating;
    }).toList();

    switch (sortBy) {
      case 'Nearest':
        filtered.sort((a, b) {
          final distanceCompare = a.mockDistanceKm.compareTo(b.mockDistanceKm);
          return distanceCompare != 0 ? distanceCompare : a.name.compareTo(b.name);
        });
        break;
      case 'Most Reviewed':
        filtered.sort((a, b) {
          final reviewsCompare = b.ratingCount.compareTo(a.ratingCount);
          return reviewsCompare != 0 ? reviewsCompare : a.name.compareTo(b.name);
        });
        break;
      case 'Top Rated':
      default:
        filtered.sort((a, b) {
          final ratingCompare = b.ratingAvg.compareTo(a.ratingAvg);
          return ratingCompare != 0 ? ratingCompare : a.name.compareTo(b.name);
        });
        break;
    }

    return filtered;
  }
}
