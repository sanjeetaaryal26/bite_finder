import '../../data/models/restaurant_model.dart';
import '../constants/app_constants.dart';

class RestaurantFilter {
  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<String> _tokens(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) {
      return [];
    }
    return normalized.split(' ');
  }

  static int _editDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (var j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[b.length];
  }

  static bool _tokenMatchesText({
    required String token,
    required String normalizedText,
    required List<String> textTokens,
  }) {
    if (token.isEmpty) return true;
    if (normalizedText.contains(token)) return true;
    for (final t in textTokens) {
      if (t.startsWith(token)) return true;
      final maxDistance = token.length <= 4 ? 1 : 2;
      if ((t.length - token.length).abs() <= maxDistance && _editDistance(t, token) <= maxDistance) {
        return true;
      }
    }
    return false;
  }

  static int _searchScore(RestaurantModel restaurant, String query) {
    final queryNorm = _normalize(query);
    if (queryNorm.isEmpty) return 0;
    final queryTokens = _tokens(queryNorm);

    final nameNorm = _normalize(restaurant.name);
    final cuisineNorm = _normalize(restaurant.cuisines.join(' '));
    final specialtyNorm = _normalize(restaurant.specialties.join(' '));
    final bestSellerNorm = _normalize(restaurant.bestSellers.join(' '));
    final locationNorm = _normalize(restaurant.location);
    final descriptionNorm = _normalize(restaurant.description);
    final allNorm = [nameNorm, cuisineNorm, specialtyNorm, bestSellerNorm, locationNorm, descriptionNorm].join(' ');

    final nameTokens = _tokens(nameNorm);
    final cuisineTokens = _tokens(cuisineNorm);
    final specialtyTokens = _tokens(specialtyNorm);
    final bestSellerTokens = _tokens(bestSellerNorm);
    final locationTokens = _tokens(locationNorm);
    final allTokens = _tokens(allNorm);

    var score = 0;
    if (nameNorm.contains(queryNorm)) {
      score += 80;
    }
    if (allNorm.contains(queryNorm)) {
      score += 30;
    }

    for (final token in queryTokens) {
      if (_tokenMatchesText(token: token, normalizedText: nameNorm, textTokens: nameTokens)) {
        score += 20;
        continue;
      }
      if (_tokenMatchesText(token: token, normalizedText: cuisineNorm, textTokens: cuisineTokens)) {
        score += 12;
        continue;
      }
      if (_tokenMatchesText(token: token, normalizedText: specialtyNorm, textTokens: specialtyTokens)) {
        score += 10;
        continue;
      }
      if (_tokenMatchesText(token: token, normalizedText: bestSellerNorm, textTokens: bestSellerTokens)) {
        score += 8;
        continue;
      }
      if (_tokenMatchesText(token: token, normalizedText: locationNorm, textTokens: locationTokens)) {
        score += 7;
        continue;
      }
      if (_tokenMatchesText(token: token, normalizedText: allNorm, textTokens: allTokens)) {
        score += 4;
      }
    }

    return score;
  }

  static List<RestaurantModel> apply({
    required List<RestaurantModel> restaurants,
    required String query,
    String? selectedCuisine,
    required bool highRatingOnly,
    required String sortBy,
    double? userLatitude,
    double? userLongitude,
  }) {
    final queryNorm = _normalize(query);
    final queryTokens = _tokens(queryNorm);
    final scores = <String, int>{};

    var filtered = restaurants.where((restaurant) {
      final score = _searchScore(restaurant, queryNorm);
      scores[restaurant.id] = score;

      final matchesQuery = queryTokens.isEmpty || score > 0;

      final matchesCuisine = selectedCuisine == null || selectedCuisine == 'All'
          ? true
          : restaurant.cuisines.any((c) => c.toLowerCase() == selectedCuisine.toLowerCase());

      final matchesRating = !highRatingOnly || restaurant.ratingAvg >= AppConstants.highRatingThreshold;

      return matchesQuery && matchesCuisine && matchesRating;
    }).toList();

    if (queryTokens.isNotEmpty) {
      filtered.sort((a, b) {
        final scoreCompare = (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0);
        return scoreCompare != 0 ? scoreCompare : a.name.compareTo(b.name);
      });
      return filtered;
    }

    switch (sortBy) {
      case 'Nearest':
        filtered.sort((a, b) {
          final aDistance = (userLatitude != null && userLongitude != null)
              ? a.distanceFrom(userLatitude: userLatitude, userLongitude: userLongitude)
              : null;
          final bDistance = (userLatitude != null && userLongitude != null)
              ? b.distanceFrom(userLatitude: userLatitude, userLongitude: userLongitude)
              : null;

          if (aDistance == null && bDistance == null) {
            return a.name.compareTo(b.name);
          }
          if (aDistance == null) {
            return 1;
          }
          if (bDistance == null) {
            return -1;
          }

          final distanceCompare = aDistance.compareTo(bDistance);
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
