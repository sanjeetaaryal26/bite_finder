import 'package:birdle/data/models/restaurant_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseRestaurant = RestaurantModel(
    id: 'r1',
    name: 'Sample Restaurant',
    cuisines: ['Nepali'],
    location: 'Kathmandu',
    description: 'Sample description',
    specialties: ['Momo'],
    services: ['Dine-in'],
    ratingAvg: 4.5,
    ratingCount: 100,
    priceRange: r'$$',
    photos: ['https://example.com/1.jpg'],
    bestSellers: ['Buff Momo'],
    latitude: 27.7172,
    longitude: 85.3240,
  );

  group('RestaurantModel', () {
    test('distanceFrom returns zero for same coordinates', () {
      final distance = baseRestaurant.distanceFrom(userLatitude: 27.7172, userLongitude: 85.3240);
      expect(distance, isNotNull);
      expect(distance!, lessThan(0.001));
    });

    test('distanceFrom returns null if restaurant has no coordinates', () {
      final withoutCoordinates = baseRestaurant.copyWith().toJson()
        ..['latitude'] = null
        ..['longitude'] = null;
      final restaurant = RestaurantModel.fromJson(withoutCoordinates);

      final distance = restaurant.distanceFrom(userLatitude: 27.7172, userLongitude: 85.3240);
      expect(distance, isNull);
    });

    test('copyWith only updates provided fields', () {
      final updated = baseRestaurant.copyWith(ratingAvg: 4.8, ratingCount: 220);

      expect(updated.ratingAvg, 4.8);
      expect(updated.ratingCount, 220);
      expect(updated.name, baseRestaurant.name);
      expect(updated.latitude, baseRestaurant.latitude);
    });

    test('toJson/fromJson roundtrip keeps key values', () {
      final roundTrip = RestaurantModel.fromJson(baseRestaurant.toJson());
      expect(roundTrip.id, baseRestaurant.id);
      expect(roundTrip.name, baseRestaurant.name);
      expect(roundTrip.cuisines, baseRestaurant.cuisines);
      expect(roundTrip.bestSellers, baseRestaurant.bestSellers);
      expect(roundTrip.latitude, baseRestaurant.latitude);
      expect(roundTrip.longitude, baseRestaurant.longitude);
    });
  });
}
