import 'package:birdle/core/utils/hash_utils.dart';
import 'package:birdle/core/utils/id_generator.dart';
import 'package:birdle/core/utils/restaurant_filter.dart';
import 'package:birdle/core/utils/validators.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:flutter_test/flutter_test.dart';

RestaurantModel _r({
  required String id,
  required String name,
  required List<String> cuisines,
  required double rating,
  required int reviews,
  List<String> specialties = const ['Momo'],
  List<String> bestSellers = const ['Steam Momo'],
  double? lat,
  double? lon,
}) {
  return RestaurantModel(
    id: id,
    name: name,
    cuisines: cuisines,
    location: 'Kathmandu',
    description: 'desc',
    specialties: specialties,
    services: const ['Dine-in'],
    ratingAvg: rating,
    ratingCount: reviews,
    priceRange: '\$',
    photos: const [],
    bestSellers: bestSellers,
    latitude: lat,
    longitude: lon,
  );
}

void main() {
  group('Use Cases: Validators', () {
    test('requiredField returns error for null', () {
      expect(Validators.requiredField(null, fieldName: 'Name'), 'Name is required');
    });

    test('requiredField returns null for non-empty value', () {
      expect(Validators.requiredField(' Dipesh ', fieldName: 'Name'), isNull);
    });

    test('email returns error for invalid email', () {
      expect(Validators.email('invalid@'), 'Enter a valid email');
    });

    test('email returns null for valid trimmed email', () {
      expect(Validators.email('  user@example.com  '), isNull);
    });

    test('password enforces minimum length', () {
      expect(Validators.password('12345'), 'Password must be at least 6 characters');
    });

    test('confirmPassword validates exact match', () {
      expect(Validators.confirmPassword('abc124', 'abc123'), 'Passwords do not match');
    });
  });

  group('Use Cases: Utilities and Filtering', () {
    test('hashPassword returns deterministic SHA256', () {
      expect(
        HashUtils.hashPassword('password123'),
        'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
      );
    });

    test('IdGenerator creates unique values with prefix', () {
      final one = IdGenerator.next('fb');
      final two = IdGenerator.next('fb');
      expect(one.startsWith('fb_'), true);
      expect(two.startsWith('fb_'), true);
      expect(one == two, false);
    });

    test('RestaurantFilter matches fuzzy query against name tokens', () {
      final data = [
        _r(id: '1', name: 'Momo Corner', cuisines: const ['Nepali'], rating: 4.2, reviews: 40),
        _r(
          id: '2',
          name: 'Pizza Hub',
          cuisines: const ['Pizza'],
          rating: 4.6,
          reviews: 100,
          specialties: const ['Margherita'],
          bestSellers: const ['Pepperoni Pizza'],
        ),
      ];

      final out = RestaurantFilter.apply(
        restaurants: data,
        query: 'momoo',
        selectedCuisine: 'All',
        highRatingOnly: false,
        sortBy: 'Top Rated',
      );

      expect(out.length, 1);
      expect(out.first.id, '1');
    });

    test('RestaurantFilter applies high rating, cuisine, and nearest sort', () {
      final data = [
        _r(id: '1', name: 'Near Nepali', cuisines: const ['Nepali'], rating: 4.2, reviews: 30, lat: 27.7000, lon: 85.3000),
        _r(id: '2', name: 'Far Nepali', cuisines: const ['Nepali'], rating: 4.7, reviews: 200, lat: 28.0000, lon: 85.6000),
        _r(id: '3', name: 'Near Pizza', cuisines: const ['Pizza'], rating: 4.8, reviews: 300, lat: 27.7010, lon: 85.3010),
      ];

      final out = RestaurantFilter.apply(
        restaurants: data,
        query: '',
        selectedCuisine: 'Nepali',
        highRatingOnly: true,
        sortBy: 'Nearest',
        userLatitude: 27.7005,
        userLongitude: 85.3005,
      );

      expect(out.map((r) => r.id).toList(), ['1', '2']);
    });
  });
}
