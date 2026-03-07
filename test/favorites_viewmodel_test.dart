import 'package:birdle/data/sources/mock_restaurant_data.dart';
import 'package:birdle/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_repositories.dart';

void main() {
  group('FavoritesViewModel', () {
    test('load populates favorites from repository', () async {
      final repo = FakeRestaurantRepository()..favorites = MockRestaurantData.restaurants.take(2).toList();
      final vm = FavoritesViewModel(repo);

      await vm.load('user-1');

      expect(vm.isLoading, false);
      expect(vm.favorites.length, 2);
      expect(repo.getFavoritesCalls, 1);
    });

    test('refresh delegates to load and fetches again', () async {
      final repo = FakeRestaurantRepository()..favorites = MockRestaurantData.restaurants.take(1).toList();
      final vm = FavoritesViewModel(repo);

      await vm.refresh('user-1');
      await vm.refresh('user-1');

      expect(repo.getFavoritesCalls, 2);
    });

    test('load keeps app stable when repository throws', () async {
      final repo = FakeRestaurantRepository()..throwOnGetFavorites = true;
      final vm = FavoritesViewModel(repo);

      await vm.load('user-1');

      expect(vm.isLoading, false);
      expect(vm.favorites, isEmpty);
      expect(vm.error, isNull);
    });
  });
}
